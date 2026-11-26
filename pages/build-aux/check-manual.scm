(use-modules (chinese-fonts-overlay pages manual validation)
             (ice-9 match))

(catch #t
       (lambda ()
         (match (cdr (command-line))
           ((directory) (validate-manual directory))
           (_ (error "Usage: check-manual.scm DIRECTORY"))))
       (lambda (key . arguments)
         (print-exception (current-error-port) #f key arguments)
         (exit 1)))
