(use-modules (ice-9 format)
             (ice-9 match)
             (ice-9 textual-ports)
             (srfi srfi-1))

(define (css-string value)
  "Format VALUE as a double-quoted CSS string literal."
  (string-append
   "\""
   (string-concatenate
    (map (lambda (character)
           (let ((code (char->integer character)))
             (cond
              ((or (char=? character #\\) (char=? character #\"))
               (string #\\ character))
              ((< code #x20)
               (format #f "\\~x " code))
              (else (string character)))))
         (string->list value)))
   "\""))

(define (parse-replacements css? arguments)
  "Convert flat KEY VALUE pairs into placeholder replacement entries."
  (let loop ((rest arguments) (entries '()))
    (match rest
      (() (reverse entries))
      ((key value . tail)
       (let* ((token (string-append "@" key "@"))
              ;; CSS keeps placeholders quoted so its source is parseable.
              (placeholder (if css? (string-append "\"" token "\"") token))
              (replacement (if css? (css-string value) (object->string value))))
         (loop tail (cons (cons placeholder replacement) entries))))
      (_ (error "Usage: substitute.scm INPUT OUTPUT KEY VALUE ...")))))

(define (replace-once template substitutions)
  "Replace placeholder tokens in TEMPLATE in a single pass."
  (call-with-output-string
   (lambda (port)
     (let loop ((start 0))
       (let ((next
              (fold (lambda (entry found)
                      (let ((position (string-contains template (car entry) start)))
                        (if (and position
                                 (or (not found) (< position (car found))))
                            (cons position entry)
                            found)))
                    #f substitutions)))
         (if next
             (begin
               (display (substring template start (car next)) port)
               (display (cddr next) port)
               (loop (+ (car next) (string-length (cadr next)))))
             (display (substring template start) port)))))))

(match (cdr (command-line))
  ((input output . replacements)
   (let* ((entries (parse-replacements (string-suffix? ".css" input)
                                       replacements))
          (text (call-with-input-file input
                  (lambda (port)
                    (set-port-encoding! port "UTF-8")
                    (get-string-all port))))
          (rendered (replace-once text entries)))
     (call-with-output-file output
       (lambda (port)
         (set-port-encoding! port "UTF-8")
         (display rendered port)))))
  (_
   (error "Usage: substitute.scm INPUT OUTPUT KEY VALUE ...")))
