(define-module (chinese-fonts-overlay-site interface)
  #:use-module (chinese-fonts-overlay-site util)
  #:export (prepare-interface))

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

(define (prepare-interface output)
  "Prepare interface font CSS in OUTPUT, preserving unchanged files."
  (mkdir-p output)
  (let ((css
         (string-append
          (face-css "YuYang" "400" "normal" "yuyang-regular.ttf" "truetype")
          (face-css "YuYang" "500 900" "normal" "yuyang-medium.ttf" "truetype")))
        (target (string-append output "/fonts.css")))
    (unless (and (file-exists? target) (equal? css (read-text target)))
      (atomic-write target (lambda (file) (write-text file css))))))
