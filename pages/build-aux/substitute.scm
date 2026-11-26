(use-modules ((chinese-fonts-overlay pages presentation layout)
              #:select (substitute-template))
             (chinese-fonts-overlay pages util)
             (ice-9 format)
             (ice-9 match))

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

(define (parse-replacements arguments)
  "Convert flat KEY VALUE pairs into quoted CSS placeholder entries."
  (let loop ((rest arguments) (entries '()))
    (match rest
      (() (reverse entries))
      ((key value . tail)
       (let ((placeholder (string-append "\"@" key "@\"")))
         (loop tail (cons (cons placeholder (css-string value)) entries))))
      (_ (error "Usage: substitute.scm INPUT OUTPUT KEY VALUE ...")))))

(match (cdr (command-line))
  ((input output . replacements)
   (let ((entries (parse-replacements replacements)))
     (write-text output (substitute-template (read-text input) entries))))
  (_
   (error "Usage: substitute.scm INPUT OUTPUT KEY VALUE ...")))
