(use-modules (chinese-fonts-overlay pages preview inputs)
             (ice-9 match))

(catch #t
       (lambda ()
         (match (cdr (command-line))
           ((root destination) (prepare-inputs (canonicalize-path root) destination))
           (_ (error "Usage: inputs.scm ROOT DESTINATION"))))
       (lambda (key . args)
         (print-exception (current-error-port) #f key args)
         (exit 1)))
