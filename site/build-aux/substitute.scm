(use-modules (ice-9 match)
             (ice-9 textual-ports)
             (ice-9 string-fun))

(match (cdr (command-line))
  ((input output . replacements)
   (let loop ((text
               (call-with-input-file
                   input
                 (lambda (port)
                   (set-port-encoding! port "UTF-8")
                   (get-string-all port))))
              (rest replacements))
     (match rest
       (()
        (call-with-output-file
            output
          (lambda (port)
            (set-port-encoding! port "UTF-8")
            (display text port))))
       ((key value . tail)
        (let* ((token (string-append "@" key "@"))
               ;; CSS keeps placeholders quoted so its source is parseable.
               (placeholder (if (string-suffix? ".css" input)
                                (object->string token)
                                token)))
          (loop (string-replace-substring
                 text
                 placeholder
                 (if (string=? key "GUILE")
                     value
                     (object->string value)))
                tail))))))
  (_
   (error "usage: substitute.scm INPUT OUTPUT KEY VALUE ...")))
