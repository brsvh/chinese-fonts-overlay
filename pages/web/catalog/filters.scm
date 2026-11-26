(define-module (catalog filters)
  #:use-module (catalog host)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-13)
  #:export (initialize-filters! restore-filters! save-filters!
            sync-filters! apply-filters!))

(define (contains-text? text query)
  "Match QUERY at Scheme character boundaries; Hoot lacks string-contains."
  (let ((limit (- (string-length text) (string-length query))))
    (let loop ((start 0))
      (and (<= start limit)
           (or (string=?
                query
                (substring text start (+ start (string-length query))))
               (loop (+ start 1)))))))

(define-record-type <facet>
  (make-facet key options all defaults)
  facet?
  (key facet-key)
  (options facet-options)
  (all facet-all)
  (defaults facet-defaults))

(define facets '())

(define packages '())

(define language-facet #f)
(define displayed-order "default")

(define (facet-selection facet)
  "Return checked values in FACET's stable option order."
  (map element-value
       (filter (lambda (option) (= 1 (checked? option)))
               (facet-options facet))))

(define (set-facet-selection! facet values)
  "Set FACET selection to VALUES, including options in collapsed sections."
  (for-each
   (lambda (option)
     (set-checked! option (if (member (element-value option) values) 1 0)))
   (facet-options facet)))

(define (sync-select-all! facet)
  "Reflect complete, partial and empty selection in the heading checkbox."
  (let ((count (length (facet-selection facet)))
        (total (length (facet-options facet))))
    (set-checked! (facet-all facet) (if (= count total) 1 0))
    (set-indeterminate!
     (facet-all facet)
     (if (and (> count 0) (< count total)) 1 0))))

(define (restore-filters! defaults?)
  "Restore defaults or URL state; star means all, empty means none."
  (let ((url (current-url)))
    (for-each
     (lambda (facet)
       (let* ((fallback (string-join (facet-defaults facet) ","))
              (value (if defaults?
                         fallback
                         (url-parameter url (facet-key facet) fallback)))
              (choices (map element-value (facet-options facet)))
              (values
               (if (string=? value "*")
                   choices
                   (filter
                    (lambda (key) (member key choices))
                    (string-split value #\,)))))
         (set-facet-selection! facet values)
         (sync-select-all! facet)))
     facets)
    (set-value!
     (element-by-id "query")
     (if defaults? "" (url-parameter url "query" "")))
    (set-checked!
     (element-by-id "embedding")
     (if (and (not defaults?)
              (string=? (url-parameter url "embedding" "") "true"))
         1
         0))
    (set-value!
     (element-by-id "sort")
     (if (and (not defaults?) (string=? (url-parameter url "sort" "") "name"))
         "name"
         "default"))
    (let* ((size (and (not defaults?)
                      (string->number (url-parameter url "size" "66"))))
           (valid? (and (exact-integer? size) (<= 36 size 96) (even? size))))
      (set-value!
       (element-by-id "size")
       (if valid? (number->string size) "66")))))

(define (save-filters!)
  "Push a shareable state, omitting defaults without conflating all and none."
  (let ((url (current-url)))
    (for-each
     (lambda (facet)
       (let ((values (facet-selection facet)))
         (if (equal? values (facet-defaults facet))
             (delete-parameter! url (facet-key facet))
             (set-parameter!
              url
              (facet-key facet)
              (if (= (length values) (length (facet-options facet)))
                  "*"
                  (string-join values ","))))))
     facets)
    (for-each
     (lambda (entry)
       (if (string-null? (cdr entry))
           (delete-parameter! url (car entry))
           (set-parameter! url (car entry) (cdr entry))))
     (list (cons "query" (element-value (element-by-id "query")))
           (cons "embedding"
                 (if (= 1 (checked? (element-by-id "embedding"))) "true" ""))
           (cons "sort"
                 (if (string=? (element-value (element-by-id "sort")) "name")
                     "name"
                     ""))
           (cons "size"
                 (let ((size (element-value (element-by-id "size"))))
                   (if (string=? size "66") "" size)))))
    (push-url! url)))

(define (package-matches? row selections text embedding?)
  "Match any selected value within each group and require every group to match."
  (and (contains-text?
        (string-downcase (element-attribute row "data-search"))
        text)
       (or (not embedding?)
           (string=? (element-attribute row "data-embedding") "true"))
       (let loop ((rest selections))
         (or (null? rest)
             (and (let ((actual
                         (string-split
                          (element-attribute
                           row
                           (string-append "data-" (caar rest)))
                          #\space)))
                    (let any ((values (cdar rest)))
                      (and (pair? values)
                           (or (member (car values) actual) (any (cdr values))))))
                  (loop (cdr rest)))))))

(define (order-packages! order)
  "Move existing cards only when the selected ordering changes."
  (unless (string=? order displayed-order)
    (let ((container (element-by-id "packages"))
          (rows (if (string=? order "name")
                    (stable-sort packages
                                 (lambda (a b)
                                   (string<? (element-attribute a "data-name")
                                             (element-attribute b "data-name"))))
                    packages)))
      (for-each (lambda (row) (append-child! container row)) rows)
      (set! displayed-order order))))

(define (sync-filters! save?)
  "Reflect selections in the group controls and optionally update the URL."
  (for-each sync-select-all! facets)
  (when save? (save-filters!)))

(define (apply-filters! language-labels)
  "Update the result list and language badge; return the selected language tags."
  (let* ((selections
          (map (lambda (facet) (cons (facet-key facet) (facet-selection facet)))
               facets))
         (text (string-downcase
                (string-trim-both (element-value (element-by-id "query")))))
         (embedding? (= 1 (checked? (element-by-id "embedding"))))
         (languages (facet-selection language-facet))
         (visible 0))
    (order-packages! (element-value (element-by-id "sort")))
    (for-each
     (lambda (row)
       (let ((show? (package-matches? row selections text embedding?)))
         (set-hidden! row (if show? 0 1))
         (when show? (set! visible (+ visible 1)))))
     packages)
    (set-text!
     (element-by-id "result-count")
     (string-append
      (number->string visible)
      " / "
      (number->string (length packages))
      " 个字体包"))
    (set-hidden! (element-by-id "empty-results") (if (= visible 0) 0 1))
    (set-text!
     (element-by-id "current-language")
     (cond ((null? languages) "未选择语言")
           ((= (length languages) (length (facet-options language-facet))) "全部语言")
           (else (string-join (map (lambda (tag) (json-text language-labels tag))
                                   languages)
                              "、"))))
    languages))

(define (initialize-filters! on-change)
  "Bind the rendered facets and notify ON-CHANGE when a selection changes."
  (set! packages (nodes "#packages > article"))
  (set! facets
        (map (lambda (group)
               (let* ((key (element-attribute group "data-facet"))
                      (default-raw (element-attribute group "data-default"))
                      (facet (make-facet
                              key
                              (nodes (string-append "[data-choice='" key "']"))
                              (element-query group "[data-select-all]")
                              (if (string-null? default-raw)
                                  '()
                                  (string-split default-raw #\,)))))
                 (when (string=? key "language") (set! language-facet facet))
                 (listen!
                  (facet-all facet)
                  "change"
                  (lambda ()
                    (set-facet-selection!
                     facet
                     (if (= 1 (checked? (facet-all facet)))
                         (map element-value (facet-options facet))
                         '()))
                    (on-change #t)))
                 (for-each
                  (lambda (option)
                    (listen! option "change"
                             (lambda () (on-change #t))))
                  (facet-options facet))
                 facet))
             (nodes "[data-facet]")))
  (restore-filters! #f))
