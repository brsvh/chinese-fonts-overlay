(define-module (chinese-fonts-overlay-update-font-languages command)
  #:use-module (chinese-fonts-overlay-update-font-languages coverage)
  #:export (main))

(define (checkout)
  "Locate the repository above the current directory."
  (let loop ((directory (getcwd)))
    (cond ((file-exists? (string-append directory "/.git")) directory)
          ((string=? directory (dirname directory))
           (error "Use --source-root to select the font repository"))
          (else (loop (dirname directory))))))

(define (main arguments)
  "Scan ARGUMENTS, optionally updating package languages; return exit status."
  (catch #t
         (lambda ()
           (cond
            ((or (null? arguments) (member "--help" arguments))
             (display "Usage: chinese-fonts-overlay-update-font-languages [OPTIONS] PACKAGE...

PACKAGE is a full attribute (naverPackages.maru-buri) or a package.nix path.
  --package PACKAGE   Select another package (repeatable).
  --all               Select every package in the repository.
  --check             Fail if recorded language coverage is stale.
  --write             Update language lists after all scans succeed.
  --output FILE       Write the coverage report to FILE instead of stdout.
  --source-root DIR   Select the repository explicitly.
  --help              Show this help.

Without --check or --write, only report detected coverage.
")
             0)
            (else
             ;; The scanner resolves an explicit source root before using this default.
             (update-font-languages
              (if (any-source-root? arguments) (getcwd) (checkout)) arguments))))
         (lambda (key . arguments)
           (print-exception (current-error-port) #f key arguments)
           1)))

(define (any-source-root? arguments)
  "Recognize either getopt spelling of an explicit source root in ARGUMENTS."
  (let loop ((rest arguments))
    (and (pair? rest)
         (or (string=? (car rest) "--source-root")
             (string-prefix? "--source-root=" (car rest))
             (loop (cdr rest))))))
