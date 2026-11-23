(define-module (chinese-fonts-overlay-site build)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (chinese-fonts-overlay-site previews)
  #:use-module (chinese-fonts-overlay-site catalog)
  #:use-module (chinese-fonts-overlay-site manual)
  #:use-module (chinese-fonts-overlay-site layout)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 regex)
  #:export (build-site))

(define* (build-site catalog-file previews-file cache output revision
                     #:key prepared manual)
  "Build a complete static site in staging and preserve OUTPUT on failure."
  (unless (and (string? revision) (string-match "^[0-9a-f]{40}$" revision))
    (error "Expected a full source commit SHA" revision))
  (let* ((catalog (read-json catalog-file))
         (parent (dirname output))
         (temporary (temporary-directory parent))
         (staging (string-append temporary "/public"))
         (backup (string-append temporary "/previous"))
         (published? #f))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (if prepared
              (for-each
               (lambda (file)
                 (let ((destination
                        (string-append staging
                                       (substring file (string-length prepared)))))
                   (mkdir-p (dirname destination))
                   (copy-file file destination)))
               (files-under prepared))
              (prepare-previews catalog (read-json previews-file) cache staging
                                output))
          (render-catalog catalog staging revision)
          (install-manual manual staging revision)
          (write-text
           (string-append staging "/licenses.html")
           (string-replace-substring
            (string-replace-substring
             (read-text (web-file "licenses.html"))
             "<!-- site-presentation -->" (site-presentation-head "./"))
            "<!-- site-loader -->" (site-loader)))
          (for-each
           (lambda (name)
             (copy-file (web-file name) (string-append staging "/" name)))
           '("bridge.js" "presentation.js" "manual.js" "main.wasm" "reflect.js"
             "reflect.wasm" "wtf8.wasm" "fonts.css" "style.css"
             "favicon.svg" "cc0.svg" "yuyang-regular.ttf"
             "yuyang-medium.ttf" "tsanger-license.pdf"))
          (when (file-exists? output)
            (rename-file output backup))
          (catch 'system-error
                 (lambda () (rename-file staging output) (set! published? #t))
                 (lambda args
                   (when (file-exists? backup)
                     (rename-file backup output))
                   (apply throw args))))
        (lambda ()
          (if (and (file-exists? backup) (not published?))
              (format (current-error-port)
                      "Previous website retained at ~a~%" backup)
              (delete-tree temporary))))))
