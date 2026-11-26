(define-module (chinese-fonts-overlay pages manual navigation)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:export (manual-navigation internal-links))

(define (internal-links file)
  "Read Texinfo's tab-separated internal link report from FILE."
  (filter-map
   (lambda (line)
     (let ((fields (string-split line #\tab)))
       (and (= 3 (length fields)) fields)))
   (string-split (read-text file) #\newline)))

(define (section-tree entries depth)
  "Return a tree at DEPTH and the unconsumed section ENTRIES as two values."
  (let loop ((rest entries) (result '()))
    (if (or (null? rest) (< (caar rest) depth))
        (values (reverse result) rest)
        (let ((entry (car rest)))
          (unless (= (car entry) depth)
            (error "Skipped a manual heading level" entry))
          (let-values (((children remaining)
                        (section-tree (cdr rest) (+ depth 1))))
            (loop remaining
                  (cons `(("href" . ,(cadr entry))
                          ("label" . ,(caddr entry))
                          ("children" . ,(list->vector children))) result)))))))

(define (manual-navigation file)
  "Derive the complete heading hierarchy from Texinfo's own FILE report."
  (let ((sections
         (filter-map
          (lambda (row)
            (and (equal? (cadr row) "section")
                 (let ((match
                           (string-match
                            (string-append
                             "^(top|chapter|unnumbered|section|subsection) "
                             "([0-9.]+ )?(.*)$")
                            (caddr row))))
                   (and match
                        (list (cond ((equal? (match:substring match 1)
                                             "section") 1)
                                    ((equal? (match:substring match 1)
                                             "subsection") 2)
                                    (else 0))
                              (car row) (match:substring match 3))))))
          (internal-links file))))
    (let-values (((tree remaining) (section-tree sections 0)))
      (unless (null? remaining)
        (error "Incomplete manual navigation" remaining))
      (list->vector tree))))
