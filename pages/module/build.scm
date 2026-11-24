(define-module (build)
  #:use-module (util)
  #:use-module (preview images)
  #:use-module (preview catalog)
  #:use-module (manual page)
  #:use-module (presentation fonts)
  #:use-module (presentation layout)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:export (build-site build-pages))

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
             (string-replace-substring
              (read-text (web-file "licenses.html"))
              "<!-- site-presentation -->" (site-presentation-head "./"))
             "<!-- site-loader -->" (site-loader))
            "<!-- commercial-font-notice -->"
            (if (file-exists? (web-file "concourse_ot_3_book.woff2"))
                (string-append
                 "<p>西文字体为 Concourse，等宽字体为 Triplicate A Code，"
                 "由 Matthew Butterick 设计。本站依购买许可使用原始 WOFF2 文件；"
                 "字体不适用网站代码的 CC0 许可。</p>"
                 "<p><a href=\"https://mbtype.com/\">MB Type</a> · "
                 "<a href=\"https://mbtype.com/license\">字体许可</a></p>")
                "")))
          (for-each
           (lambda (name)
             (copy-file (web-file name) (string-append staging "/" name)))
           (append
            '("bridge.js" "presentation.js" "manual.js" "main.wasm" "reflect.js"
              "reflect.wasm" "wtf8.wasm" "fonts.css" "style.css"
              "favicon.svg" "cc0.svg" "yuyang-regular.ttf"
              "yuyang-medium.ttf" "tsanger-license.pdf")
            (filter (lambda (name) (file-exists? (web-file name)))
                    commercial-font-names)))
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

(define (fingerprint files values)
  "Hash FILES by content together with the ordered configuration VALUES."
  (text-digest
   (object->string
    (cons values (map (lambda (file) (cons file (file-digest file))) files)))))

(define (file-state file)
  "Describe FILE's identity, size and modification state without reading it."
  (let ((info (stat file)))
    (list file (stat:ino info) (stat:size info)
          (stat:mtime info) (stat:mtimensec info)
          (stat:ctime info) (stat:ctimensec info))))

(define (output-digest digest directory)
  "Combine the input DIGEST with the state of every file in DIRECTORY."
  (text-digest
   (object->string (cons digest (map file-state (files-under directory))))))

(define (current? stamp digest output)
  "Check that STAMP matches DIGEST and the complete OUTPUT tree is unchanged."
  (and (file-exists? stamp) (file-exists? output)
       (string=? (output-digest digest output) (read-text stamp))))

(define (record! stamp digest output)
  "Record DIGEST and the complete published OUTPUT tree."
  (let ((value (output-digest digest output)))
    (atomic-write stamp (lambda (file) (write-text file value)))))

(define (font-inputs inputs)
  "Track immutable store paths, or file changes in explicit local font inputs."
  (map
   (lambda (entry)
     (let ((path (canonicalize-path (jref (cdr entry) "renderPath"))))
       (cons (car entry)
             (if (string-prefix? "/nix/store/" path) path
                 (map file-state (filter font-file? (files-under path)))))))
   inputs))

(define (build-pages root directory cache catalog-file fonts-file revision manual)
  "Build DIRECTORY/public from declared inputs, reusing unchanged stage outputs."
  (let* ((catalog (read-json catalog-file))
         (fonts (read-json fonts-file))
         (web (string-append directory "/web"))
         (preview-output (string-append directory "/previews"))
         (preview-stamp (string-append directory "/previews.sha256"))
         (output (string-append directory "/public"))
         (stamp (string-append directory "/public.sha256"))
         (module-root (string-append root "/module/"))
         (preview-digest
          (fingerprint
           (append
            (map (lambda (name) (string-append module-root name))
                 '("preview/images.scm" "preview/samples.scm" "util.scm"))
            (list (string-append root "/etc/language-samples.json")
                  (getenv "FONT_SITE_INSPECTOR") (getenv "FONT_SITE_RENDERER")))
           (list (map (lambda (package)
                        (list (jref package "id") (jref package "languages")))
                      (jarray (jref catalog "packages")))
                 (font-inputs fonts)
                 (capture (getenv "FONT_SITE_RENDERER") "--encoder-version")))))
    (unless (current? preview-stamp preview-digest preview-output)
      (let* ((temporary (temporary-directory directory))
             (staging (string-append temporary "/previews")))
        (dynamic-wind
            (lambda () #t)
            (lambda ()
              (prepare-previews catalog fonts cache staging preview-output)
              (when (file-exists? preview-output) (delete-tree preview-output))
              (rename-file staging preview-output)
              (record! preview-stamp preview-digest preview-output))
            (lambda () (delete-tree temporary)))))
    (let ((digest
           (fingerprint
            (append (list catalog-file
                          (string-append module-root "build.scm")
                          (string-append module-root "preview/catalog.scm")
                          (string-append module-root "presentation/layout.scm")
                          (string-append module-root "presentation/fonts.scm")
                          (string-append module-root "manual/page.scm")
                          (string-append root "/build-aux/build.scm"))
                    (files-under (string-append root "/etc"))
                    (files-under manual)
                    (files-under web))
            (list revision preview-digest))))
      (if (current? stamp digest output)
          (format #t "Website is up to date: ~a~%" output)
          (begin
            (build-site catalog-file fonts-file cache output revision
                        #:prepared preview-output #:manual manual)
            (record! stamp digest output)
            (format #t "Built website: ~a~%" output))))))
