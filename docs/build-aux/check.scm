(use-modules (chinese-fonts-overlay-manual validation))

(catch #t
       (lambda () (validate-manual (cadr (command-line))))
       (lambda (key . arguments)
         (print-exception (current-error-port) #f key arguments)
         (exit 1)))
