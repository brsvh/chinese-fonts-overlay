(define-module (preview inputs)
  #:use-module (util)
  #:use-module (json)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (web uri)
  #:export (prepare-inputs))

(define (prepare-inputs root destination)
  "Refresh catalog and private font inputs from ROOT when source content changes."
  (let* ((selection (sort (delete-duplicates
                          (string-tokenize (or (getenv "PACKAGES") "")))
                         string<?))
         (paths (append-map
                 (lambda (name) (files-under (string-append root "/" name)))
                 '("packages" "overlays" "lib")))
         (files (sort
                 (append (filter (lambda (path) (string-suffix? ".nix" path))
                                 paths)
                         (map (lambda (name) (string-append root "/" name))
                              '("flake.nix" "flake.lock" "default.nix"
                                "pages/module/preview/inputs.scm"
                                "pages/etc/inputs.nix" "pages/build-aux/inputs.scm")))
                 string<?))
         (digest (text-digest
                  (object->string
                   (cons selection
                         (map (lambda (file) (cons file (file-digest file)))
                              files)))))
         (stamp (string-append destination "/source.sha256"))
         (catalog (string-append destination "/catalog.json"))
         (previews (string-append destination "/fonts.json")))
    (unless (and (file-exists? stamp) (string=? digest (read-text stamp))
                 (file-exists? catalog) (file-exists? previews)
                 (every (lambda (entry)
                          (file-exists? (jref (cdr entry) "renderPath")))
                        (read-json previews)))
      (let* ((path
              (string-trim-both
               (capture
                "env" (string-append "FONT_SITE_SOURCE_ROOT=" root)
                (string-append "FONT_SITE_PACKAGES="
                               (scm->json-string (list->vector selection)))
                (string-append "FONT_SITE_SOURCE_FLAKE=git+file://"
                               (string-join
                                (map uri-encode (string-split root #\/)) "/"))
                "nix" "build" "--impure" "--no-link" "--print-out-paths"
                "--file" (string-append root "/pages/etc/inputs.nix"))))
             (inputs (read-json path)))
        (atomic-write catalog
                      (lambda (file) (write-json file (jref inputs "catalog"))))
        (atomic-write previews
                      (lambda (file) (write-json file (jref inputs "previews"))))
        (atomic-write stamp (lambda (file) (write-text file digest)))))))
