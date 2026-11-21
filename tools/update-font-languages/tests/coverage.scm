(use-modules (chinese-fonts-overlay-update-font-languages coverage)
             (chinese-fonts-overlay-update-font-languages util)
             (rnrs bytevectors)
             (rnrs io ports)
             (srfi srfi-1)
             (srfi srfi-64))

(test-begin "coverage")

(define runner (test-runner-current))

(define source
  "{
  passthru = {
    chinese-fonts-overlay-site = {
      displayName = \"测试字体\";
      languages = [ \"en\" ];
      licenseCost = \"free\";
      styles = [ \"sans\" ];
      vendor = \"test\";
    };
  };
}
")

(test-equal "Replace only language list"
            "{
  passthru = {
    chinese-fonts-overlay-site = {
      displayName = \"测试字体\";
      languages = [
        \"en\"
        \"zh-cn\"
      ];
      licenseCost = \"free\";
      styles = [ \"sans\" ];
      vendor = \"test\";
    };
  };
}
"
            (replace-languages source '("en" "zh-cn")))

(test-equal "Refuse to rewrite an unrecognized source file"
            "Expected exactly one literal chinese-fonts-overlay-site block"
            (catch 'misc-error
                   (lambda () (replace-languages "{}" '("en")))
                   (lambda (key subr message arguments data) (car arguments))))

(let ((coverage (scan-fonts (getenv "FONT_LANGUAGES_FIXTURES"))))
  (test-equal "Coverage report includes both collection members"
              '((0 "First") (1 "Second"))
              (map (lambda (face) (list (jref face "index") (jref face "family")))
                   (filter (lambda (face) (equal? (jref face "file") "collection.ttc"))
                           (jarray (jref coverage "faces"))))))

(define (write-coverage-font file ranges)
  "Map RANGES to the CC0 fixture's triangle glyph in a valid temporary TTF FILE."
  (let* ((template
          (call-with-input-file
              (string-append (getenv "FONT_LANGUAGES_FIXTURES") "/static.ttf")
            get-bytevector-all))
         (offset (* 4 (ceiling (/ (bytevector-length template) 4))))
         (cmap-size (+ 28 (* 12 (length ranges))))
         (font (make-bytevector (+ offset cmap-size) 0))
         (tables (iota (bytevector-u16-ref template 4 (endianness big)) 12 16)))
    (define (put16 offset value)
      "Write a big-endian unsigned 16-bit VALUE into FONT at OFFSET."
      (bytevector-u16-set! font offset value (endianness big)))
    (define (put32 offset value)
      "Write a big-endian unsigned 32-bit VALUE into FONT at OFFSET."
      (bytevector-u32-set! font offset value (endianness big)))
    (define (table-record tag)
      "Find the SFNT directory record for TAG in the copied fixture."
      (find (lambda (record)
              (every (lambda (index)
                       (= (bytevector-u8-ref font (+ record index))
                          (char->integer (string-ref tag index))))
                     '(0 1 2 3)))
            tables))
    (define (checksum start end)
      "Sum the aligned big-endian words in FONT between START and END."
      (modulo
       (fold (lambda (index total)
               (+ total (bytevector-u32-ref font index (endianness big))))
             0 (iota (/ (- end start) 4) start 4))
       (expt 2 32)))
    (bytevector-copy! template 0 font 0 (bytevector-length template))
    ;; A format 13 cmap maps each inclusive range to the same nonempty glyph.
    (put16 (+ offset 2) 1)
    (put16 (+ offset 4) 3)
    (put16 (+ offset 6) 10)
    (put32 (+ offset 8) 12)
    (put16 (+ offset 12) 13)
    (put32 (+ offset 16) (- cmap-size 12))
    (put32 (+ offset 24) (length ranges))
    (for-each
     (lambda (range index)
       (let ((group (+ offset 28 (* index 12))))
         (put32 group (car range))
         (put32 (+ group 4) (cdr range))
         (put32 (+ group 8) 1)))
     ranges (iota (length ranges)))
    (let ((record (table-record "cmap"))
          (head (bytevector-u32-ref font (+ (table-record "head") 8)
                                    (endianness big))))
      (put32 (+ record 4) (checksum offset (bytevector-length font)))
      (put32 (+ record 8) offset)
      (put32 (+ record 12) cmap-size)
      (put32 (+ head 8) 0)
      (put32 (+ head 8)
             (modulo (- #xb1b0afba (checksum 0 (bytevector-length font)))
                     (expt 2 32))))
    (call-with-output-file file (lambda (port) (put-bytevector port font)))))

(let ((temporary (temporary-directory (or (getenv "TMPDIR") "/tmp"))))
  (dynamic-wind
      (lambda () #t)
      (lambda ()
        (for-each
         (lambda (entry)
           (write-coverage-font (string-append temporary "/" (car entry) ".ttf")
                                (cdr entry)))
         '(("modern" (#x3131 . #x3163) (#xac00 . #xd7a3))
           ("missing-syllable" (#x3131 . #x3163)
            (#xac00 . #xac01) (#xac03 . #xd7a3))
           ("missing-jamo" (#xac00 . #xd7a3))
           ("letters-only" (#x3131 . #x3163))))
        (let* ((coverage (scan-fonts temporary))
               (faces (jarray (jref coverage "faces"))))
          (test-equal "Modern Korean is found without archaic jamo, per face"
                      '("modern.ttf")
                      (map (lambda (face) (jref face "file"))
                           (filter (lambda (face)
                                     (member "ko" (jarray (jref face "languages"))))
                                   faces)))
          (test-equal "The package retains the recognized Korean language"
                      '("ko") (jarray (jref coverage "languages")))))
      (lambda () (delete-tree temporary))))

(let* ((temporary (temporary-directory (or (getenv "TMPDIR") "/tmp")))
       (file (string-append temporary "/package.nix"))
       (sources (list (cons "naverPackages.maru-buri" file))))
  (dynamic-wind
      (lambda () (write-text file source))
      (lambda ()
        (test-equal "Attributes and package paths select the same package once"
                    '("naverPackages.maru-buri")
                    (resolve-packages (list "naverPackages.maru-buri" file) sources))
        (test-equal "Unknown selectors fail before scanning or writing"
                    "Unknown package attribute or package.nix path"
                    (catch 'misc-error
                           (lambda () (resolve-packages '("naver.maru-buri") sources))
                           (lambda (key subr message arguments data) (car arguments)))))
      (lambda () (delete-tree temporary))))

(test-end "coverage")

(exit (zero? (test-runner-fail-count runner)))
