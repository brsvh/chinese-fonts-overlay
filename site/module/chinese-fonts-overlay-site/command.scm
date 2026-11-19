(define-module (chinese-fonts-overlay-site command)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (chinese-fonts-overlay-site previews)
  #:use-module (chinese-fonts-overlay-site catalog)
  #:use-module (chinese-fonts-overlay-site coverage)
  #:use-module (chinese-fonts-overlay-site server)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 regex)
  #:export (main))

(define (nonempty text)
  "Return TEXT only when it is a nonempty string."
  (and (string? text) (not (string-null? text)) text))

(define (checkout)
  "Locate SOURCE_ROOT or the nearest Git checkout, falling back to the cwd."
  (or (nonempty (getenv "SOURCE_ROOT"))
      (let loop ((directory (getcwd)))
        (cond ((file-exists? (string-append directory "/.git")) directory)
              ((string=? directory (dirname directory)) (getcwd))
              (else (loop (dirname directory)))))))

(define (build-site catalog-file previews-file cache output revision)
  "Build a complete static site in staging and preserve OUTPUT on failure."
  (unless (and (string? revision) (string-match "^[0-9a-f]{40}$" revision))
    (error "Expected a full source commit SHA" revision))
  (unless (nonempty previews-file)
    (let ((derivation (nonempty (getenv "PREVIEWS_DERIVATION"))))
      (when derivation
        (set! previews-file
              (string-trim-both
               (capture "nix-store" "--realise" derivation))))))
  (unless (and (nonempty catalog-file) (nonempty previews-file))
    (error
     (string-append "Catalog and preview inputs are required; "
                    "use nix run .#site or pass --catalog and --previews")))
  (let* ((catalog (read-json catalog-file))
         (parent (dirname output))
         (temporary (temporary-directory parent))
         (staging (string-append temporary "/public"))
         (backup (string-append temporary "/previous"))
         (published? #f))
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (prepare-previews
         catalog
         (read-json previews-file)
         cache
         staging
         output)
        (render-catalog catalog staging revision)
        (for-each
         (lambda (name)
           (copy-file (web-file name) (string-append staging "/" name)))
         '("bridge.js" "main.wasm" "reflect.js" "reflect.wasm" "wtf8.wasm"))
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

(define (help)
  "Print supported command-line options without reading font inputs."
  (display
   "Usage: chinese-fonts-overlay-site [--build | --serve-only] [OPTIONS]
       chinese-fonts-overlay-site update-font-info --package ID [--write | --check]

Build the static catalog and serve it on http://127.0.0.1:8000.

  --build             Build the website without starting the server.
  --serve-only        Serve existing output without rebuilding.
  --port PORT         Listen on PORT (1-65535).
  --catalog FILE      Evaluated public font catalog JSON.
  --previews FILE     Private font renderer input JSON.
  --source-root DIR   Font repository checkout.
  --revision SHA      Full source commit SHA (for builds without Git).
  --output DIR        Static output (default: SOURCE_ROOT/site/dist).
  --cache DIR         Build cache (default: SOURCE_ROOT/site/.cache).
  --help              Show this help.
  --version           Show the version.

Language scan options: --package ID (repeatable), --all, --write, --check,
                      --output FILE, --source-root DIR.
"))

(define (main arguments)
  "Run ARGUMENTS and return an exit status, reporting failures on stderr."
  (catch #t
    (lambda ()
      (if (and (pair? arguments)
               (equal? (car arguments) "update-font-info"))
          (update-font-info (checkout) (cdr arguments))
          (let* ((options
                  (getopt-long
                   (cons "chinese-fonts-overlay-site" arguments)
                   '((help (single-char #\h) (value #f))
                     (version (value #f))
                     (build (value #f))
                     (serve-only (value #f))
                     (port (value #t))
                     (catalog (value #t))
                     (previews (value #t))
                     (source-root (value #t))
                     (revision (value #t))
                     (output (value #t))
                     (cache (value #t)))))
                 (get (lambda (key fallback)
                        (or (nonempty (option-ref options key #f)) fallback))))
            (cond
             ((option-ref options 'help #f) (help) 0)
             ((option-ref options 'version #f)
              (format
               #t
               "chinese-fonts-overlay-site ~a~%"
               (or (getenv "FONT_SITE_VERSION") "0.1.0"))
              0)
             (else (unless (null? (option-ref options '() '()))
                     (error "Unexpected positional arguments"))
                   (when (and (option-ref options 'build #f)
                              (option-ref options 'serve-only #f))
                     (error "Use either --build or --serve-only"))
                   (let* ((root (canonicalize-path
                                 (get 'source-root (checkout))))
                          (output
                           (get 'output (string-append root "/site/dist")))
                          (cache (get 'cache
                                      (string-append root "/site/.cache")))
                          (port-text (get 'port "8000"))
                          (port (and (string-match "^[0-9]{1,5}$" port-text)
                                     (string->number port-text))))
                     (unless (and port (< 0 port 65536))
                       (error "Port must be an integer between 1 and 65535"))
                     (unless (option-ref options 'serve-only #f)
                       (let ((revision
                              (get 'revision
                                   (nonempty (getenv "SOURCE_REVISION")))))
                         (unless revision
                           (set! revision
                                 (string-trim-both
                                  (capture
                                   "git"
                                   "-C"
                                   root
                                   "rev-parse"
                                   "--verify"
                                   "HEAD^{commit}"))))
                         (build-site
                          (get 'catalog (getenv "CATALOG"))
                          (get 'previews (getenv "PREVIEWS"))
                          cache
                          output
                          revision)))
                     (unless (option-ref options 'build #f)
                       (serve-site output port))
                     0))))))
    (lambda (key . args)
      (print-exception (current-error-port) #f key args)
      1)))
