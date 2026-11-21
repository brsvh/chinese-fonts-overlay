(use-modules (chinese-fonts-overlay-site archive)
             (chinese-fonts-overlay-site deployment)
             (chinese-fonts-overlay-site util)
             (srfi srfi-1)
             (srfi srfi-64))

(define root (temporary-directory "/tmp"))
(define source (make-string 40 #\a))
(define current source)
(define notification
  `(("action" . "site-ready")
    ("repository" . (("id" . 772409384)))
    ("sender" . (("id" . 47349067)))
    ("client_payload" . (("source" . ,source) ("release" . 77)
                         ("archive" . 11) ("manifest" . 12)))))
(define assets '())
(define paths '())

(define (failure thunk)
  "Return a boundary error message, without accepting unrelated exceptions."
  (catch 'misc-error thunk
         (lambda (key procedure message arguments . rest)
           (apply format #f message arguments))))

(define (api token path . options)
  "Supply trusted API metadata for the end-to-end receiver fixture."
  (cond
   ((equal? path "/git/ref/heads/main")
    `(("object" . (("type" . "commit") ("sha" . ,current)))))
   ((equal? path "/releases/tags/site-artifacts")
    '(("id" . 77) ("tag_name" . "site-artifacts")
      ("draft" . #f) ("prerelease" . #t)))
   ((equal? path "/releases/77/assets?per_page=100&page=1")
    (list->vector assets))
   (else (error "Unexpected fixture API request" path))))

(define (download asset destination)
  "Deliver fixture bytes through the receiver's ordinary archive validator."
  (copy-file (assoc-ref paths (jref asset "id")) destination))

(module-set! (resolve-module '(chinese-fonts-overlay-site github))
             'github-request api)
(module-set! (resolve-module '(chinese-fonts-overlay-site github))
             'download-asset download)

(test-begin "site-deployment")
(define runner (test-runner-current))
(dynamic-wind
    (lambda () #t)
    (lambda ()
      (let ((public (string-append root "/input")))
        (mkdir public)
        (for-each (lambda (name) (write-text (string-append public "/" name) name))
                  '("index.html" "licenses.html" "style.css" "bridge.js"
                    "catalog.json" "previews.json" "main.wasm" "reflect.js"
                    "reflect.wasm" "wtf8.wasm" "favicon.svg" "cc0.svg"
                    "tsanger-license.pdf" "yuyang-regular.ttf" "yuyang-medium.ttf"))
        (write-json (string-append public "/catalog.json")
                    `(("sourceRevision" . ,source)))
        (for-each (lambda (asset)
                    (setenv (cdr asset) (string-append public "/" (car asset))))
                  '(("yuyang-regular.ttf" . "UI_FONT_REGULAR")
                    ("yuyang-medium.ttf" . "UI_FONT_MEDIUM")
                    ("tsanger-license.pdf" . "UI_FONT_LICENSE")))
        (let* ((release (string-append root "/release"))
               (manifest (pack-site public source release))
               (base (release-name manifest)))
          (set! assets
                (map (lambda (id suffix)
                       (let* ((name (string-append base suffix))
                              (path (string-append release "/" name)))
                         (set! paths (acons id path paths))
                         `(("id" . ,id) ("name" . ,name) ("state" . "uploaded")
                           ("size" . ,(stat:size (stat path)))
                           ("digest" . ,(string-append "sha256:" (file-digest path)))
                           ("uploader" . (("id" . 47349067))))))
                     '(11 12) '(".tar.gz" ".json")))
          (for-each (lambda (entry) (setenv (car entry) (cdr entry)))
                    `(("GITHUB_REPOSITORY" . "brsvh/chinese-fonts-overlay")
                      ("GITHUB_REF" . "refs/heads/main")
                      ("GITHUB_WORKFLOW_REF" .
                       "brsvh/chinese-fonts-overlay/.github/workflows/site-deploy.yml@refs/heads/main")
                      ("GITHUB_EVENT_NAME" . "repository_dispatch")
                      ("GITHUB_TOKEN" . "fixture")
                      ("GITHUB_EVENT_PATH" . ,(string-append root "/event.json"))
                      ("GITHUB_OUTPUT" . ,(string-append root "/outputs"))))
          (write-json (getenv "GITHUB_EVENT_PATH") notification)
          (receive-site (string-append root "/public"))
          (test-assert "Receive authenticated archive through extraction"
                       (and (file-exists? (string-append root "/public/index.html"))
                            (string-prefix? "ready=true\n" (read-text (getenv "GITHUB_OUTPUT")))))
          (set! current (make-string 40 #\b))
          (receive-site (string-append root "/stale"))
          (test-assert "Skip a superseded source without extracting"
                       (and (not (file-exists? (string-append root "/stale")))
                            (equal? "ready=false\n" (read-text (getenv "GITHUB_OUTPUT")))))
          (set! current source)
          (test-assert "Reject a dispatch from a different publisher"
                       (string-contains
                        (failure (lambda () (validate-notification
                                             (jset notification "sender" '(("id" . 1))))))
                        "Invalid site-ready notification"))
          (set! assets (cons (jset (car assets) "uploader" '(("id" . 1)))
                             (cdr assets)))
          (test-assert "Reject a substituted asset before extraction"
                       (and (string-contains
                             (failure (lambda () (receive-site (string-append root "/substituted"))))
                             "Invalid site asset identity or publisher")
                            (not (file-exists? (string-append root "/substituted")))))
          (setenv "GITHUB_EVENT_NAME" "workflow_dispatch")
          (write-json (getenv "GITHUB_EVENT_PATH") `(("inputs" . (("release" . ,base)))))
          (test-assert "Rollback cannot deploy an archive with no success receipt"
                       (string-contains
                        (failure (lambda () (receive-site (string-append root "/unpublished"))))
                        "Rollback requires a previously successful deployment"))))
      (test-equal "Retain current and two previous distinct deployments"
                  '(5 4 3)
                  (select-retained (map (lambda (id) `(("archive" . ,id))) '(5 4 5 3 2 1)))))
    (lambda () (delete-tree root)))
(test-end "site-deployment")
(exit (and (zero? (test-runner-fail-count runner))
           (zero? (test-runner-xpass-count runner))))
