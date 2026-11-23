(use-modules (chinese-fonts-overlay-site util)
             (ice-9 match))

(define (clean kind source directory)
  "Remove only known KIND products beneath DIRECTORY, never SOURCE itself."
  (when (file-exists? directory)
    (let ((directory (canonicalize-path directory))
          (source (canonicalize-path source)))
      (when (or (string=? directory "/") (string=? directory source)
                (string-prefix? (string-append directory "/") source))
        (error "Refusing to clean the source tree or an ancestor" directory))
      (for-each
       (lambda (name) (delete-tree (string-append directory "/" name)))
       (match kind
         ("build" '("bin" "web" "inputs" "tests" "previews" "public" "docs"
                    "native.settings" "web.settings" "previews.sha256"
                    "public.sha256"))
         ("cache" '("font-records" "language-images"))
         (_ (error "Unknown cleanup kind" kind)))))))

(match (cdr (command-line))
  ((kind source directory) (clean kind source directory))
  (_ (error "Usage: clean.scm build|cache SOURCE DIRECTORY")))
