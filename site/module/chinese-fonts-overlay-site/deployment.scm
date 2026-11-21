(define-module (chinese-fonts-overlay-site deployment)
  #:use-module (chinese-fonts-overlay-site archive)
  #:use-module (chinese-fonts-overlay-site github)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (ice-9 ftw)
  #:use-module (srfi srfi-1)
  #:export (validate-notification validate-asset select-retained
                                  site-build site-upload receive-site check-current record-deployment))

(define repository-id 772409384)
(define hercules-id 47349067)
(define actions-id 41898282)
(define state-directory "/site-state")
(define workflow-path ".github/workflows/site-deploy.yml")

(define (revision? value)
  "Recognize a full lowercase Git commit identifier."
  (matches? "^[0-9a-f]{40}$" value))

(define (release-base? value)
  "Recognize an immutable site archive basename."
  (matches? "^site-[0-9a-f]{40}-[0-9a-f]{64}$" value))

(define (main-revision token)
  "Read the current remote main commit, without accepting tag indirection."
  (let* ((reference (github-request token "/git/ref/heads/main"))
         (object (jref reference "object"))
         (source (jref object "sha")))
    (require-value (and (equal? (jref object "type") "commit") (revision? source))
                   "Invalid main branch reference")
    source))

(define (artifact-release token)
  "Resolve the dedicated non-draft prerelease used for artifact handoff."
  (let ((release (github-request token "/releases/tags/site-artifacts")))
    (require-value (and (positive-id? (jref release "id"))
                        (equal? (jref release "tag_name") "site-artifacts")
                        (eq? (jref release "draft") #f)
                        (eq? (jref release "prerelease") #t))
                   "Invalid site artifact release")
    release))

(define (release-assets token release)
  "Read every asset of the verified artifact release."
  (github-pages token (string-append "/releases/"
                                     (number->string (jref release "id"))
                                     "/assets")))

(define (validate-asset asset name owner)
  "Validate a release asset's identity, publisher, size, state and hash."
  (require-value
   (and (positive-id? (jref asset "id"))
        (equal? (jref asset "name") name)
        (equal? (jref asset "state") "uploaded")
        (equal? (jref (jref asset "uploader" '()) "id") owner)
        (positive-id? (jref asset "size"))
        (< (jref asset "size") 1000000000)
        (matches? "^sha256:[0-9a-f]{64}$" (jref asset "digest")))
   "Invalid site asset identity or publisher")
  asset)

(define (validate-notification event)
  "Authenticate a site-ready dispatch and validate its small payload."
  (let ((payload (jref event "client_payload")))
    (require-value
     (and (equal? (jref event "action") "site-ready")
          (equal? (jref (jref event "repository" '()) "id") repository-id)
          (equal? (jref (jref event "sender" '()) "id") hercules-id)
          (list? payload)
          (equal? (sort (map car payload) string<?)
                  '("archive" "manifest" "release" "source"))
          (revision? (jref payload "source"))
          (every (lambda (key) (positive-id? (jref payload key)))
                 '("archive" "manifest" "release")))
     "Invalid site-ready notification")
    payload))

(define (environment name)
  "Read a required nonempty environment value."
  (let ((value (getenv name)))
    (require-value (and value (not (string-null? value)))
                   "Missing environment variable" name)
    value))

(define (hercules-token)
  "Read the short-lived token only within the expected repository Effect."
  (require-value (equal? (getenv "HERCULES_CI_PROJECT_PATH")
                         (string-append "github/" repository))
                 "Unexpected Hercules project")
  (jref (jref (jref (read-json (environment "HERCULES_CI_SECRETS_JSON"))
                    "git") "data") "token"))

(define (site-build source)
  "Queue a fresh-credential upload job, then build through Make privately."
  (require-value (revision? source) "Invalid site source revision")
  (let ((token (hercules-token)))
    (when (equal? source (main-revision token))
      ;; Effects of a later job wait for this job to finish. The queued job gets
      ;; a fresh GitToken even if the font collection takes hours to render.
      (let* ((nonce (string-trim-both (read-text "/proc/sys/kernel/random/uuid")))
             (tag (string-append "ci/site/" source "/" nonce))
             (release (string-append state-directory "/releases/" source)))
        (require-value (matches? "^[0-9a-f-]{36}$" nonce) "Invalid request nonce")
        (github-request token "/git/refs" #:method "POST"
                        #:data `(("ref" . ,(string-append "refs/tags/" tag))
                                 ("sha" . ,source)))
        (run "git" "-c" "http.version=HTTP/1.1" "clone" "--no-checkout"
             "--filter=blob:none" "--single-branch" "--branch" "main"
             (string-append "https://github.com/" repository ".git") "source")
        (run "git" "-C" "source" "checkout" "--detach" source)
        (require-value (equal? source (string-trim-both
                                       (capture "git" "-C" "source" "rev-parse" "HEAD")))
                       "Unexpected source checkout")
        (let* ((root (canonicalize-path "source"))
               (build (string-append state-directory "/build"))
               (cache (string-append state-directory "/cache"))
               (arguments (list "nix" "develop" "--no-write-lock-file"
                                "--no-update-lock-file" (string-append root "#site")
                                "-c" "make" "-C" (string-append root "/site") "-j2"
                                (string-append "BUILD_DIR=" build)
                                (string-append "CACHE_DIR=" cache)
                                (string-append "SOURCE_REVISION=" source))))
          (apply run (append arguments '("check")))
          (apply run (append arguments '("all")))
          (mkdir-p (dirname release))
          (let ((temporary (temporary-directory (dirname release))))
            (dynamic-wind
                (lambda () #t)
                (lambda ()
                  (let ((packed (string-append temporary "/release")))
                    (apply run (append arguments
                                       (list "release" (string-append "RELEASE_DIR=" packed))))
                    (when (file-exists? release) (delete-tree release))
                    (rename-file packed release)))
                (lambda () (delete-tree temporary)))))))))

(define (site-upload source)
  "Upload immutable artifacts with a fresh token and notify the Pages receiver."
  (require-value (revision? source) "Invalid site source revision")
  (let ((token (hercules-token)))
    (when (equal? source (main-revision token))
      (let* ((directory (string-append state-directory "/releases/" source))
             (manifests (scandir directory (lambda (name) (string-suffix? ".json" name)))))
        (require-value (= 1 (length manifests)) "Missing completed site release")
        (let* ((manifest (validate-release (read-json
                                            (string-append directory "/" (car manifests)))))
               (base (release-name manifest))
               (release (artifact-release token))
               (assets (release-assets token release)))
          (require-value (equal? source (jref manifest "source")) "Wrong staged revision")
          (let* ((published
                  (map
                   (lambda (suffix)
                     (let* ((name (string-append base suffix))
                            (file (string-append directory "/" name))
                            (existing (find (lambda (asset)
                                              (equal? name (jref asset "name")))
                                            assets))
                            (asset (or existing
                                       (upload-asset token (jref release "id") file
                                                     (if (equal? suffix ".json")
                                                         "application/json" "application/gzip")))))
                       (validate-asset asset name hercules-id)
                       (require-value (equal? (jref asset "digest")
                                              (string-append "sha256:" (file-digest file)))
                                      "Existing release asset differs; refusing replacement")
                       (jref asset "id")))
                   '(".tar.gz" ".json"))))
            (when (equal? source (main-revision token))
              (github-request token "/dispatches" #:method "POST"
                              #:data `(("event_type" . "site-ready")
                                       ("client_payload" .
                                        (("release" . ,(jref release "id"))
                                         ("archive" . ,(car published))
                                         ("manifest" . ,(cadr published))
                                         ("source" . ,source)))))
              (write-text (string-append directory "/.uploaded") "")
              (prune-staged-releases))))))))

(define (prune-staged-releases)
  "Keep three uploaded local archives; preserve pending staged releases."
  (let* ((root (string-append state-directory "/releases"))
         (uploaded
          (filter (lambda (name)
                    (file-exists? (string-append root "/" name "/.uploaded")))
                  (scandir root revision?)))
         (ordered
          (sort uploaded
                (lambda (a b)
                  (> (stat:mtime (stat (string-append root "/" a "/.uploaded")))
                     (stat:mtime (stat (string-append root "/" b "/.uploaded"))))))))
    (for-each (lambda (name) (delete-tree (string-append root "/" name)))
              (drop ordered (min 3 (length ordered))))))

(define (receipt? asset)
  "Recognize only deployment receipts uploaded by GitHub Actions."
  (and (matches? "^site-deployed-[0-9]+-[0-9]+\\.json$" (jref asset "name"))
       (equal? (jref (jref asset "uploader" '()) "id") actions-id)))

(define (read-asset-json asset)
  "Read a bounded, hash-verified JSON release asset."
  (require-value (<= (jref asset "size") 65536) "JSON asset too large")
  (let ((temporary (temporary-directory (or (getenv "TMPDIR") "/tmp"))))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (let ((path (string-append temporary "/data.json")))
            (download-asset asset path)
            (read-json path)))
        (lambda () (delete-tree temporary)))))

(define (deployment-receipts token assets)
  "Read verified successful deployment receipts, newest first."
  (filter-map
   (lambda (asset)
     (validate-asset asset (jref asset "name") actions-id)
     (let ((record (read-asset-json asset)))
       (require-value
        (and (equal? (jref record "schema") 1)
             (release-base? (jref record "base"))
             (every (lambda (key) (positive-id? (jref record key)))
                    '("run" "attempt" "archive" "manifest")))
        "Invalid deployment receipt")
       (let* ((run-path (string-append "/actions/runs/" (number->string (jref record "run"))
                                       "/attempts/" (number->string (jref record "attempt"))))
              (run (github-request token run-path))
              (jobs (github-pages token (string-append run-path "/jobs") "jobs")))
         (and (equal? (jref run "path") workflow-path)
              (equal? (jref run "head_branch") "main")
              (member (jref run "event") '("repository_dispatch" "workflow_dispatch"))
              (any (lambda (job) (and (equal? (jref job "name") "Deploy website")
                                      (equal? (jref job "conclusion") "success"))) jobs)
              record))))
   (sort (filter receipt? assets)
         (lambda (a b) (string>? (jref a "created_at") (jref b "created_at"))))))

(define (select-retained receipts)
  "Keep the three most recently deployed distinct archive IDs."
  (take (delete-duplicates (map (lambda (record) (jref record "archive")) receipts))
        (min 3 (length (delete-duplicates
                        (map (lambda (record) (jref record "archive")) receipts))))))

(define (actions-context)
  "Require execution of trusted main-branch workflow code in this repository."
  (require-value (and (equal? (getenv "GITHUB_REPOSITORY") repository)
                      (equal? (getenv "GITHUB_REF") "refs/heads/main")
                      (equal? (getenv "GITHUB_WORKFLOW_REF")
                              (string-append repository "/" workflow-path "@refs/heads/main")))
                 "Unexpected publication workflow context"))

(define (receive-site destination)
  "Authenticate an event, validate its archive and emit safe deployment outputs."
  (actions-context)
  (let* ((token (environment "GITHUB_TOKEN"))
         (event (read-json (environment "GITHUB_EVENT_PATH")))
         (automatic? (equal? (getenv "GITHUB_EVENT_NAME") "repository_dispatch"))
         (release (artifact-release token))
         (assets (release-assets token release))
         (request
          (if automatic?
              (validate-notification event)
              (let* ((base (jref (jref event "inputs" '()) "release"))
                     (receipt (and (release-base? base)
                                   (find (lambda (record) (equal? base (jref record "base")))
                                         (deployment-receipts token assets)))))
                (require-value (and (equal? (getenv "GITHUB_EVENT_NAME") "workflow_dispatch")
                                    receipt)
                               "Rollback requires a previously successful deployment")
                `(("source" . ,(substring base 5 45))
                  ("release" . ,(jref release "id"))
                  ("archive" . ,(jref receipt "archive"))
                  ("manifest" . ,(jref receipt "manifest")))))))
    (require-value (equal? (jref request "release") (jref release "id"))
                   "Notification names a different release")
    (if (and automatic? (not (equal? (jref request "source") (main-revision token))))
        (write-text (environment "GITHUB_OUTPUT") "ready=false\n")
        (let* ((metadata (find (lambda (asset) (equal? (jref asset "id") (jref request "manifest"))) assets))
               (archive (find (lambda (asset) (equal? (jref asset "id") (jref request "archive"))) assets)))
          (require-value (and metadata archive) "Release assets are missing")
          (validate-asset metadata (jref metadata "name") hercules-id)
          (let* ((manifest (validate-release (read-asset-json metadata)))
                 (base (release-name manifest))
                 (temporary (temporary-directory (or (getenv "TMPDIR") "/tmp"))))
            (require-value (and (equal? (jref manifest "source") (jref request "source"))
                                (equal? (jref metadata "name") (string-append base ".json")))
                           "Manifest identity differs from notification")
            (validate-asset archive (string-append base ".tar.gz") hercules-id)
            (require-value (and (= (jref archive "size") (jref manifest "size"))
                                (equal? (jref archive "digest")
                                        (string-append "sha256:" (jref manifest "sha256"))))
                           "Archive metadata differs from manifest")
            (dynamic-wind
                (lambda () #t)
                (lambda ()
                  (let ((file (string-append temporary "/site.tar.gz")))
                    (download-asset archive file)
                    (unpack-site file manifest destination)))
                (lambda () (delete-tree temporary)))
            (write-text (environment "GITHUB_OUTPUT")
                        (format #f "ready=true~%source=~a~%base=~a~%archive=~a~%manifest=~a~%"
                                (jref manifest "source") base
                                (jref archive "id") (jref metadata "id"))))))))

(define (check-current source)
  "Skip an automatic deployment superseded since archive preparation."
  (actions-context)
  (require-value (revision? source) "Invalid deployment source")
  (write-text (environment "GITHUB_OUTPUT")
              (if (or (equal? (getenv "GITHUB_EVENT_NAME") "workflow_dispatch")
                      (equal? source (main-revision (environment "GITHUB_TOKEN"))))
                  "ready=true\n" "ready=false\n")))

(define (record-deployment base archive-id manifest-id)
  "Record a successful Pages job, then prune only older deployed artifacts."
  (actions-context)
  (require-value (and (release-base? base) (positive-id? archive-id) (positive-id? manifest-id))
                 "Invalid deployed artifact identity")
  (let* ((token (environment "GITHUB_TOKEN"))
         (run-id (string->number (environment "GITHUB_RUN_ID")))
         (attempt (string->number (environment "GITHUB_RUN_ATTEMPT")))
         (release (artifact-release token))
         (assets (release-assets token release))
         (temporary (temporary-directory (or (getenv "TMPDIR") "/tmp")))
         (name (format #f "site-deployed-~a-~a.json" run-id attempt)))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (let ((path (string-append temporary "/" name)))
            (write-json path `(("schema" . 1) ("base" . ,base) ("run" . ,run-id)
                               ("attempt" . ,attempt) ("archive" . ,archive-id)
                               ("manifest" . ,manifest-id)))
            (unless (find (lambda (asset) (equal? name (jref asset "name"))) assets)
              (upload-asset token (jref release "id") path "application/json"))))
        (lambda () (delete-tree temporary)))
    (let* ((receipts (deployment-receipts token (release-assets token release)))
           (retained (select-retained receipts))
           (obsolete (filter (lambda (record) (not (member (jref record "archive") retained))) receipts)))
      ;; Assets without a successful receipt are pending and are never pruned.
      (for-each
       (lambda (id)
         (let ((asset (find (lambda (asset) (equal? id (jref asset "id"))) assets)))
           (when asset
             (validate-asset asset (jref asset "name") hercules-id)
             (github-request token (string-append "/releases/assets/" (number->string id))
                             #:method "DELETE"))))
       (delete-duplicates (append-map (lambda (record) (list (jref record "archive")
                                                             (jref record "manifest"))) obsolete))))))
