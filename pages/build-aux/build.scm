(use-modules (chinese-fonts-overlay pages build)
             (ice-9 match)
             (chinese-fonts-overlay pages util))

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
              (build-site root directory cache catalog fonts revision manual)))
           (_ (error "Usage: build.scm ROOT BUILD CACHE CATALOG FONTS REVISION MANUAL"))))
       (lambda (key . args)
         (print-exception (current-error-port) #f key args)
         (exit 1)))
