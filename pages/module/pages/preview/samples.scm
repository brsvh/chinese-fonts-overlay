(define-module (chinese-fonts-overlay pages preview samples)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (srfi srfi-1)
  #:export (samples
            sample-revision
            language-label
            candidates
            supported-samples
            catalog-languages
            default-language))

(define (data-file name)
  "Resolve NAME relative to the configured private data directory."
  (string-append
   (or (nonempty-env "FONT_PAGES_DATA") (error "FONT_PAGES_DATA is not set"))
   "/"
   name))

(define samples (delay (read-json (data-file "language-samples.json"))))
(define language-labels (delay (read-json (data-file "language-names.json"))))
(define sample-revision
  (delay (file-digest (data-file "language-samples.json"))))

(define (language-label tag)
  "Return the reviewed Chinese name for TAG; reject missing names."
  (or (jref (force language-labels) tag)
      (error "Missing Simplified Chinese language name" tag)))

(define (candidates tag)
  "Return ordered text/kind pairs for TAG; reject missing mappings."
  (let* ((entry (or (jref (force samples) tag)
                    (error "Missing language samples" tag)))
         (kind (jref entry "kind")))
    (append
     (list (cons (jref entry "text") kind))
     (map (lambda (text) (cons text kind))
          (jarray (jref entry "alternatives" #())))
     (if (jref entry "characters")
         (list (cons (jref entry "characters") "characters"))
         '()))))

(define required
  (delay (map (lambda (entry)
                (cons (car entry)
                      (map (lambda (choice)
                             (delete-duplicates
                              (map char->integer
                                   (filter
                                    (lambda (c)
                                      (and (not (char-whitespace? c))
                                           (not (eq? (char-general-category c)
                                                     'Cf))))
                                    (string->list (car choice))))))
                           (candidates (car entry)))))
              (force samples))))

(define (supported-samples characters)
  "Select the first fully covered sample per language for CHARACTERS."
  (let ((coverage (make-hash-table)))
    (for-each (lambda (cp) (hashv-set! coverage cp #t)) characters)
    (filter-map
     (lambda (entry)
       (let ((index (list-index
                     (lambda (codes)
                       (every (lambda (cp) (hashv-ref coverage cp)) codes))
                     (cdr entry))))
         (and index (cons (car entry) index))))
     (force required))))

(define (catalog-languages languages)
  "Add the Chinese group and represent empty language coverage explicitly."
  (cond
   ((null? languages) '("unknown"))
   ((any (lambda (tag)
           (member
            (car (string-split tag #\-))
            '("zh" "cmn" "hak" "lzh" "nan" "wuu" "yue")))
         languages)
    (delete-duplicates (append languages '("zh"))))
   (else languages)))

(define (default-language samples)
  "Choose a stable default from the available per-face SAMPLES."
  (or (find (lambda (tag) (assoc tag samples))
            '("zh"
              "zh-cn"
              "zh-tw"
              "ja"
              "ko"
              "ar"
              "bo"
              "hi"
              "th"
              "my"
              "km"
              "lo"
              "en"))
      (and (pair? samples) (caar samples))
      'null))
