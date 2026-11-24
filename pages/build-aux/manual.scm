(use-modules (manual build)
             (ice-9 match)
             (util))

(catch #t
       (lambda ()
         (match (cdr (command-line))
           ((source directory reference revision system)
            (let ((revision
                   (if (string-null? revision)
                       (string-trim-both (capture "git" "-C" source "rev-parse" "HEAD"))
                       revision))
                  (system
                   (if (and (string-null? system) (string-null? reference))
                       (string-trim-both
                        (capture "nix" "eval" "--impure" "--raw" "--expr"
                                 "builtins.currentSystem"))
                       system)))
              (build-manual (canonicalize-path source) directory
                            reference revision system)))
           (_ (error "Usage: manual.scm SOURCE BUILD REFERENCE REVISION SYSTEM"))))
       (lambda (key . arguments)
         (print-exception (current-error-port) #f key arguments)
         (exit 1)))
