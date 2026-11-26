(use-modules (chinese-fonts-overlay pages manual build)
             (ice-9 match)
             (chinese-fonts-overlay pages util))

(catch #t
       (lambda ()
         (match (cdr (command-line))
           ((source directory reference revision system)
            (let ((revision
                   (if (string-null? revision)
                       (string-trim-both
                        (capture "git" "-C" source "rev-parse" "--verify"
                                 "HEAD^{commit}"))
                       revision))
                  (system
                   (if (and (string-null? system) (string-null? reference))
                       (string-trim-both
                        (capture "nix" "eval" "--impure" "--raw" "--expr"
                                 "builtins.currentSystem"))
                       system)))
              (build-manual (canonicalize-path source) directory
                            reference revision system)))
           (_ (error
               (string-append "Usage: manual.scm SOURCE BUILD REFERENCE "
                              "REVISION SYSTEM")))))
       (lambda (key . arguments)
         (print-exception (current-error-port) #f key arguments)
         (exit 1)))
