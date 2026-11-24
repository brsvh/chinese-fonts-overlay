(define-module (chinese-fonts-overlay pages presentation fonts)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (srfi srfi-1)
  #:export (commercial-font-names commercial-font-inputs prepare-interface))

(define commercial-faces
  (jarray (jref (read-json (search-path %load-path "../etc/webfonts.json"))
                "faces")))

(define (face-name face)
  (basename (jref face "path")))

(define commercial-font-names (map face-name commercial-faces))

(define (commercial-font-inputs directory)
  "Map public filenames to original WOFF2 paths under purchased DIRECTORY."
  (if (or (not directory) (string-null? directory))
      '()
      (map (lambda (face)
             (cons (face-name face) (in-vicinity directory (jref face "path"))))
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
                 (map (lambda (face)
                        (face-css (jref face "family") (jref face "weight")
                                  (jref face "style") (face-name face) "woff2"))
                      commercial-faces)))))
          (target (string-append output "/fonts.css")))
      (unless (and (file-exists? target) (equal? css (read-text target)))
        (atomic-write target (lambda (file) (write-text file css)))))))
