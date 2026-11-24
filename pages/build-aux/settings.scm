(use-modules (util)
             (ice-9 match))

(match (cdr (command-line))
  ((output . settings)
   (let ((text (string-append (object->string settings) "\n")))
     (unless (and (file-exists? output) (string=? text (read-text output)))
       (atomic-write output (lambda (file) (write-text file text)))))))
