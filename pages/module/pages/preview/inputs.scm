(define-module (chinese-fonts-overlay pages preview inputs)
  #:use-module (chinese-fonts-overlay pages build inputs)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (json)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:export (prepare-inputs))

(define (prepare-inputs root destination)
  "Refresh catalog and private font inputs from ROOT when source content changes."
  (let* ((selection (sort (delete-duplicates
                          (string-tokenize (or (getenv "PACKAGES") "")))
                         string<?))
         (files (append (catalog-input-files root)
                        (map (lambda (name) (in-vicinity root name))
                             '("pages/module/pages/preview/inputs.scm"
                               "pages/etc/inputs.nix" "pages/build-aux/inputs.scm"))))
         (digest (fingerprint files selection))
         (stamp (string-append destination "/source.sha256"))
         (catalog (string-append destination "/catalog.json"))
         (font-inputs (string-append destination "/fonts.json")))
    (define (input-state)
      (fingerprint (list catalog font-inputs) digest))
    (unless (and (file-exists? stamp) (file-exists? catalog)
                 (file-exists? font-inputs) (string=? (input-state) (read-text stamp))
                 (every (lambda (entry)
                          (file-exists? (jref (cdr entry) "renderPath")))
                        (read-json font-inputs)))
      (let* ((path
              (string-trim-both
               (capture
                "env" (string-append "FONT_PAGES_SOURCE_ROOT=" root)
                (string-append "FONT_PAGES_PACKAGES="
                               (scm->json-string (list->vector selection)))
                (string-append "FONT_PAGES_SOURCE_FLAKE=" (checkout-flake-url root))
                "nix" "build" "--impure" "--no-link" "--print-out-paths"
                "--file" (string-append root "/pages/etc/inputs.nix"))))
             (inputs (read-json path)))
        (atomic-write catalog
                      (lambda (file) (write-json file (jref inputs "catalog"))))
        (atomic-write font-inputs
                      (lambda (file) (write-json file (jref inputs "fontInputs"))))
        (atomic-write stamp (lambda (file) (write-text file (input-state))))))))
