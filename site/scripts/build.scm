(use-modules (chinese-fonts-overlay-site build)
             (chinese-fonts-overlay-site previews)
             (chinese-fonts-overlay-site util)
             (ice-9 match)
             (srfi srfi-1))

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

(define (build root directory cache catalog-file fonts-file revision manual)
  "Build DIRECTORY/public from declared inputs, reusing unchanged stage outputs."
  (let* ((catalog (read-json catalog-file))
         (fonts (read-json fonts-file))
         (web (string-append directory "/web"))
         (preview-output (string-append directory "/previews"))
         (preview-stamp (string-append directory "/previews.sha256"))
         (output (string-append directory "/public"))
         (stamp (string-append directory "/public.sha256"))
         (module-root (string-append root "/module/chinese-fonts-overlay-site/"))
         (preview-digest
          (fingerprint
           (append
            (map (lambda (name) (string-append module-root name))
                 '("previews.scm" "samples.scm" "util.scm"))
            (list (string-append root "/data/language-samples.json")
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
                          (string-append module-root "catalog.scm")
                          (string-append module-root "layout.scm")
                          (string-append module-root "interface.scm")
                          (string-append module-root "manual.scm")
                          (string-append root "/scripts/build.scm"))
                    (files-under (string-append root "/data"))
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

(catch #t
       (lambda ()
         (match (cdr (command-line))
           ((root directory cache catalog fonts revision manual)
            (let ((revision
                   (if (string-null? revision)
                       (string-trim-both
                        (capture "git" "-C" root "rev-parse" "--verify"
                                 "HEAD^{commit}"))
                       revision)))
              (build root directory cache catalog fonts revision manual)))
           (_ (error "Usage: build.scm ROOT BUILD CACHE CATALOG FONTS REVISION MANUAL"))))
       (lambda (key . args)
         (print-exception (current-error-port) #f key args)
         (exit 1)))
