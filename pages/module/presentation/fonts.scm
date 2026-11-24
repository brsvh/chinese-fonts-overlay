(define-module (presentation fonts)
  #:use-module (util)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:export (commercial-font-names commercial-font-inputs prepare-interface))

;; Original webfonts only. The purchased library remains outside the checkout.
(define commercial-faces
  '(("Concourse" "400" "normal" "+ OT family/Concourse OT"
     "concourse_ot_3_book.woff2")
    ("Concourse" "400" "italic" "+ OT family/Concourse OT"
     "concourse_ot_3_book_italic.woff2")
    ("Concourse" "500" "normal" "+ OT family/Concourse OT"
     "concourse_ot_4_medium.woff2")
    ("Concourse" "600" "normal" "+ OT family/Concourse OT"
     "concourse_ot_6_semibold.woff2")
    ("Concourse" "700" "normal" "+ OT family/Concourse OT"
     "concourse_ot_7_bold.woff2")
    ("Triplicate" "400" "normal" "Triplicate A Code"
     "triplicate_a_code_regular.woff2")
    ("Triplicate" "400" "italic" "Triplicate A Code"
     "triplicate_a_code_italic.woff2")
    ("Triplicate" "700" "normal" "Triplicate A Code"
     "triplicate_a_code_bold.woff2")
    ("Triplicate" "700" "italic" "Triplicate A Code"
     "triplicate_a_code_bold_italic.woff2")))

(define commercial-font-names (map last commercial-faces))

(define (commercial-font-inputs directory)
  "Map public filenames to original WOFF2 paths under purchased DIRECTORY."
  (if (or (not directory) (string-null? directory))
      '()
      (map (match-lambda
             ((_ _ _ folder name)
              (cons name (string-append directory
                                        "/WOFF2 font files (best for web)/"
                                        folder "/" name))))
           commercial-faces)))

(define (face-css family weight style name format-name)
  "Describe an original font file, activated only after the loading gate."
  (format #f "@font-face {
  font-family: ~a;
  src: url(~s) format(~s);
  font-weight: ~a;
  font-style: ~a;
  font-display: swap;
}~%"
          family name format-name weight style))

(define (prepare-interface directory output)
  "Prepare selected fonts and CSS in OUTPUT, preserving unchanged files."
  (let ((inputs (commercial-font-inputs directory)))
    ;; Check the complete selection before changing an existing build tree.
    (for-each
     (lambda (entry)
       (unless (and (file-exists? (cdr entry))
                    (eq? 'regular (stat:type (stat (cdr entry)))))
         (error "Missing purchased interface webfont" (cdr entry))))
     inputs)
    (mkdir-p output)
    (for-each
     (lambda (entry)
       (let ((target (string-append output "/" (car entry))))
         (unless (and (file-exists? target)
                      (equal? (file-digest target) (file-digest (cdr entry))))
           (atomic-write target (lambda (file) (copy-file (cdr entry) file))))))
     inputs)
    (when (null? inputs)
      (for-each (lambda (name)
                  (let ((file (string-append output "/" name)))
                    (when (file-exists? file) (delete-file file))))
                commercial-font-names))
    (let ((css
           (string-append
            (face-css "YuYang" "400" "normal" "yuyang-regular.ttf" "truetype")
            (face-css "YuYang" "500 900" "normal" "yuyang-medium.ttf" "truetype")
            (if (null? inputs) ""
                (string-concatenate
                 (map (match-lambda
                        ((family weight style _ name)
                         (face-css family weight style name "woff2")))
                      commercial-faces)))))
          (target (string-append output "/fonts.css")))
      (unless (and (file-exists? target) (equal? css (read-text target)))
        (atomic-write target (lambda (file) (write-text file css)))))))
