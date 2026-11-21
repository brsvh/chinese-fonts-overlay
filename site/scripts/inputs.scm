(use-modules (chinese-fonts-overlay-site util)
             (ice-9 match)
             (srfi srfi-1)
             (web uri))

(define (prepare-inputs root destination)
  "Refresh catalog and private font inputs from ROOT when source content changes."
  (let* ((paths (append-map
                 (lambda (name) (files-under (string-append root "/" name)))
                 '("packages" "overlays" "lib")))
         (files (sort
                 (append (filter (lambda (path) (string-suffix? ".nix" path))
                                 paths)
                         (map (lambda (name) (string-append root "/" name))
                              '("flake.nix" "flake.lock" "default.nix"
                                "site/catalog.nix" "site/previews.nix"
                                "site/inputs.nix" "site/scripts/inputs.scm")))
                 string<?))
         (digest (text-digest
                  (object->string
                   (map (lambda (file) (cons file (file-digest file))) files))))
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
                (string-append "FONT_SITE_SOURCE_FLAKE=git+file://"
                               (string-join
                                (map uri-encode (string-split root #\/)) "/"))
                "nix" "build" "--impure" "--no-link" "--print-out-paths"
                "--file" (string-append root "/site/inputs.nix"))))
             (inputs (read-json path)))
        (atomic-write catalog
                      (lambda (file) (write-json file (jref inputs "catalog"))))
        (atomic-write previews
                      (lambda (file) (write-json file (jref inputs "previews"))))
        (atomic-write stamp (lambda (file) (write-text file digest)))))))

(catch #t
       (lambda ()
         (match (cdr (command-line))
           ((root destination) (prepare-inputs (canonicalize-path root) destination))
           (_ (error "Usage: inputs.scm ROOT DESTINATION"))))
       (lambda (key . args)
         (print-exception (current-error-port) #f key args)
         (exit 1)))
