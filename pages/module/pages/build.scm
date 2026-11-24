(define-module (chinese-fonts-overlay pages build)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (chinese-fonts-overlay pages preview images)
  #:use-module (chinese-fonts-overlay pages preview inspect)
  #:use-module (chinese-fonts-overlay pages preview catalog)
  #:use-module (chinese-fonts-overlay pages preview page)
  #:use-module (chinese-fonts-overlay pages manual page)
  #:use-module (chinese-fonts-overlay pages presentation fonts)
  #:use-module (chinese-fonts-overlay pages presentation layout)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (chinese-fonts-overlay pages presentation assets)
  #:export (build-site))

(define (assemble-site! catalog prepared manual output revision)
  "Assemble the prepared previews, manual and browser assets in OUTPUT."
  (for-each
   (lambda (file)
     (let ((target (string-append output (substring file (string-length prepared)))))
       (mkdir-p (dirname target))
       (copy-file file target)))
   (files-under prepared))
  (let* ((rendered (read-json (string-append prepared "/previews.json")))
         (indexed (index-preview-manifests! catalog rendered output revision)))
    (write-public-catalog! indexed output)
    (write-preview-page! indexed output))
  (install-manual manual output revision)
  (for-each
   (lambda (name) (copy-file (web-file name) (string-append output "/" name)))
   (append browser-assets
           (filter (lambda (name) (file-exists? (web-file name)))
                   commercial-font-names))))

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

(define (font-input-state inputs)
  "Track immutable store paths, or file changes in explicit local font inputs."
  (map
   (lambda (entry)
     (unless (and (equal? (map car (cdr entry)) '("renderPath"))
                  (string? (jref (cdr entry) "renderPath")))
       (error "Font must only have a local renderer path" (car entry)))
     (let ((path (canonicalize-path (jref (cdr entry) "renderPath"))))
       (cons (car entry)
             (if (string-prefix? "/nix/store/" path) path
                 (map file-state (filter font-file? (files-under path)))))))
   inputs))

(define (build-site root directory cache catalog-file fonts-file revision manual)
  "Build DIRECTORY/public from declared inputs, reusing unchanged stage outputs."
  (unless (and (string? revision) (string-match "^[0-9a-f]{40}$" revision))
    (error "Expected a full source commit SHA" revision))
  (let* ((catalog (read-json catalog-file))
         (fonts (read-json fonts-file))
         (web (getenv "FONT_SITE_WEB"))
         (preview-output (string-append directory "/previews"))
         (preview-stamp (string-append directory "/previews.sha256"))
         (output (string-append directory "/public"))
         (stamp (string-append directory "/public.sha256"))
         (module-root (string-append root "/module/pages/"))
         (inspection (inspection-revision))
         (preview-digest
          (fingerprint
           (list (in-vicinity module-root "preview/images.scm")
                 (getenv "FONT_SITE_RENDERER"))
           (list inspection
                 (map (lambda (package)
                        (list (jref package "id") (jref package "languages")))
                      (jarray (jref catalog "packages")))
                 (font-input-state fonts)
                 (capture (getenv "FONT_SITE_RENDERER") "--encoder-version")))))
    (unless (current? preview-stamp preview-digest preview-output)
      (replace-directory! preview-output
        (lambda (staging)
          (prepare-previews catalog fonts cache staging preview-output inspection)))
      (record! preview-stamp preview-digest preview-output))
    (let ((digest
           (fingerprint
            (append (list catalog-file
                          (string-append module-root "build.scm")
                          (string-append module-root "preview/catalog.scm")
                          (string-append module-root "preview/page.scm")
                          (string-append module-root "presentation/assets.scm")
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
            (replace-directory! output
              (lambda (staging)
                (assemble-site! catalog preview-output manual staging revision)))
            (record! stamp digest output)
            (format #t "Built website: ~a~%" output))))))
