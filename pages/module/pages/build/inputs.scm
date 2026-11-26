(define-module (chinese-fonts-overlay pages build inputs)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (srfi srfi-1)
  #:use-module (web uri)
  #:export (catalog-input-files checkout-flake-url))

(define (catalog-input-files root)
  "Return the source files shared by preview and manual metadata evaluation."
  (append (map (lambda (name) (in-vicinity root name))
               '("flake.nix" "flake.lock" "default.nix"
                 "pages/module/pages/build/inputs.scm"
                 "pages/module/pages/util.scm"))
          (append-map
           (lambda (directory)
             (filter (lambda (file) (string-suffix? ".nix" file))
                     (files-under (in-vicinity root directory))))
           '("packages" "overlays" "lib"))))

(define (checkout-flake-url root)
  "Encode a local checkout path as a Git flake URL."
  (string-append "git+file://"
                 (string-join (map uri-encode (string-split root #\/)) "/")))
