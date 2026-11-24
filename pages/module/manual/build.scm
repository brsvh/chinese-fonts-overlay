(define-module (manual build)
  #:use-module (manual reference)
  #:use-module (manual navigation)
  #:use-module (manual validation)
  #:use-module (util)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 regex)
  #:use-module (json)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (web uri)
  #:export (build-manual))

(define (fingerprint files values)
  "Hash input FILES and configuration VALUES in a stable order."
  (text-digest (object->string
                (cons values (map (lambda (file) (cons file (file-digest file)))
                                  (sort files string<?))))))

(define (reference-input root directory explicit system)
  "Return complete metadata, evaluating ROOT only when its inputs change."
  (if (not (string-null? explicit))
      (read-json explicit)
      (let* ((inputs (append
                      (append-map (lambda (part)
                                    (filter (lambda (file)
                                              (string-suffix? ".nix" file))
                                            (files-under
                                             (string-append root "/" part))))
                                  '("packages" "overlays" "lib"))
                      (map (lambda (name) (string-append root "/" name))
                           '("flake.nix" "flake.lock" "default.nix"
                             "pages/doc/reference.nix" "pages/module/manual/build.scm"))))
             (digest (fingerprint inputs (list root system)))
             (stamp (string-append directory "/reference.sha256"))
             (file (string-append directory "/reference.json")))
        (unless (and (file-exists? stamp) (file-exists? file)
                     (equal? (read-text stamp)
                             (string-append digest (file-digest file))))
          (let ((result
                 (json-string->scm
                  (capture "env" (string-append "FONT_MANUAL_SOURCE_ROOT=" root)
                           (string-append "FONT_MANUAL_SYSTEM=" system)
                           (string-append "FONT_MANUAL_SOURCE_FLAKE=git+file://"
                                          (string-join
                                           (map uri-encode (string-split root #\/))
                                           "/"))
                           "nix" "eval" "--impure" "--json"
                           "--no-update-lock-file" "--no-write-lock-file"
                           "--option" "allow-import-from-derivation" "false"
                           "--file" (string-append root "/pages/doc/reference.nix"))
                  #:ordered #t)))
            (atomic-write file (lambda (path) (write-json path result)))
            (atomic-write stamp
                          (lambda (path)
                            (write-text path (string-append digest
                                                            (file-digest file)))))))
        (read-json file))))

(define (build-manual source directory reference revision system)
  "Build complete Info and HTML manuals in DIRECTORY without realizing fonts."
  (unless (string-match "^[0-9a-f]{40}$" revision)
    (error "Expected a full source commit SHA" revision))
  (mkdir-p directory)
  (let* ((root (canonicalize-path (string-append source "/..")))
         (catalog (reference-input root directory reference system))
         (languages (string-append root "/pages/etc/language-names.json"))
         (makeinfo (or (getenv "MAKEINFO") "makeinfo"))
         (doc (string-append source "/doc"))
         (inputs (append (filter (lambda (file) (string-suffix? ".texi" file))
                                 (files-under doc))
                         (map (lambda (name) (string-append source "/module/" name))
                              '("manual/build.scm" "manual/reference.scm"
                                "manual/navigation.scm" "manual/validation.scm"
                                "util.scm"))
                         (list languages)))
         (digest (fingerprint inputs (list revision catalog makeinfo
                                           (capture makeinfo "--version"))))
         (stamp (string-append directory "/manual.sha256"))
         (output (string-append directory "/manual")))
    (define (output-state)
      (fingerprint (files-under output) (list digest)))
    (if (and (file-exists? stamp) (file-exists? output)
             (equal? (read-text stamp) (output-state)))
        (format #t "Manual is up to date: ~a~%" output)
        (let* ((temporary (temporary-directory directory))
               (staging (string-append temporary "/manual"))
               (previous (string-append temporary "/previous"))
               (main (string-append doc "/chinese-fonts-overlay.texi")))
          (dynamic-wind
              (lambda () (mkdir staging))
              (lambda ()
                (generate-reference catalog (read-json languages) staging revision)
                (run makeinfo "--no-split" "--error-limit=100" "-I" doc "-I" staging
                     "-o" (string-append staging "/chinese-fonts-overlay.info") main)
                (run makeinfo "--html" "--split=section" "--no-headers"
                     "-c" "FORMAT_MENU=menu"
                     "-c" "USE_NODES=0"
                     "-c" "NODE_FILES=0"
                     "-c" "CHAPTER_HEADER_LEVEL=1" "-c" "PROGRAM_NAME_IN_FOOTER=0"
                     "-c" "AFTER_BODY_OPEN=<!-- manual-start -->"
                     "-c" "PRE_BODY_CLOSE=<!-- manual-end -->"
                     (string-append "--internal-links=" staging "/links.tsv")
                     "-I" doc "-I" staging "-o" (string-append staging "/html") main)
                (write-json (string-append staging "/navigation.json")
                            (manual-navigation (string-append staging "/links.tsv")))
                (validate-manual staging)
                (when (file-exists? output) (rename-file output previous))
                (catch #t
                       (lambda () (rename-file staging output))
                       (lambda arguments
                         (when (file-exists? previous) (rename-file previous output))
                         (apply throw arguments)))
                (atomic-write stamp (lambda (path) (write-text path (output-state)))))
              (lambda () (delete-tree temporary)))
          (format #t "Built manual: ~a (~a packages)~%" output
                  (length (jarray (jref catalog "packages"))))))))
