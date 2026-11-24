(define-module (chinese-fonts-overlay pages preview inspect)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (chinese-fonts-overlay pages preview samples)
  #:use-module (ice-9 format)
  #:use-module (json)
  #:use-module ((rnrs unicode) #:select (string-foldcase))
  #:use-module (srfi srfi-1)
  #:export (font-file? font-records inspection-revision validate-image))

(define (inspection-revision)
  "Identify the native inspector, Scheme record logic and sample definitions."
  (let* ((modules '("preview/inspect.scm" "preview/samples.scm" "util.scm"))
         (sources (map (lambda (name)
                         (search-path %load-path
                                      (in-vicinity "chinese-fonts-overlay/pages" name)))
                       modules))
         (inspector (native-tool "FONT_SITE_INSPECTOR" "font-info")))
    (text-digest
     (object->string
      (cons (force sample-revision) (map file-digest (cons inspector sources)))))))

(define (font-file? path)
  "Recognize supported original font file suffixes without case sensitivity."
  (any (lambda (suffix) (string-suffix? suffix (string-downcase path)))
       '(".ttf" ".otf" ".ttc" ".otc")))

(define (inspect operation file)
  "Read the native OPERATION result for FILE as data, never as code."
  (call-with-input-string
   (capture (native-tool "FONT_SITE_INSPECTOR" "font-info") operation file)
   read))

(define (validate-image file)
  "Validate a transparent, nonblank lossless WebP and return its dimensions."
  (inspect "image-info" file))

(define (coordinates-json coordinates)
  "Serialize variation coordinates with the existing cache identity format."
  (string-append
   "{"
   (string-join
    (map (lambda (entry)
           (string-append
            (scm->json-string (car entry))
            ": "
            (scm->json-string (cdr entry))))
         (sort coordinates (lambda (a b) (string<? (car a) (car b)))))
    ", ")
   "}"))

(define (face<? a b)
  "Order faces by folded family name, weight, style and display name."
  (let ((af (string-foldcase (jref a "family")))
        (bf (string-foldcase (jref b "family"))))
    (cond
     ((not (string=? af bf)) (string<? af bf))
     ((not (= (jref a "weight") (jref b "weight")))
      (< (jref a "weight") (jref b "weight")))
     ((not (string=? (jref a "style") (jref b "style")))
      (string<? (jref a "style") (jref b "style")))
     (else (string<? (jref a "name") (jref b "name"))))))

(define (face-records face digest path)
  "Expand FACE into unique coordinate variants, retaining its source PATH."
  (let ((available (supported-samples (jref face "characters")))
        (seen-coordinates '()))
    (filter-map
     (lambda (variant)
       (let* ((coordinates (jref variant "coordinates"))
              (serialized (coordinates-json coordinates))
              (label (jref variant "name")))
         (and (not (member serialized seen-coordinates))
              (begin
                (set! seen-coordinates (cons serialized seen-coordinates))
                `(("key" .
                   ,(text-digest
                     (format #f "~a:~a:~a" digest
                             (jref face "index") serialized)))
                  ("name" .
                   ,(if (or (pair? coordinates) (jref face "collection"))
                        (string-append (jref face "family") " " label)
                        (jref face "fullName")))
                  ("family" . ,(jref face "family"))
                  ("weight" . ,(jref coordinates "wght" (jref face "weight")))
                  ("style" . ,(jref face "style"))
                  ("variations" . ,coordinates)
                  ("index" . ,(jref face "index"))
                  ("samples" . ,available)
                  ("file" . ,path))))))
     (jref face "variants"))))

(define (cached-font-records path digest cache)
  "Inspect PATH or read its content-keyed CACHE; keep local paths out of it."
  (let ((cache-file (in-vicinity cache (string-append digest ".json"))))
    (if (file-exists? cache-file)
        (map (lambda (record) (jset record "file" path))
             (jarray (read-json cache-file)))
        (let ((records
               (append-map (lambda (face) (face-records face digest path))
                           (inspect "inspect" path))))
          (atomic-write
           cache-file
           (lambda (file)
             (write-json file
                         (list->vector
                          (map (lambda (record) (alist-delete "file" record equal?))
                               records)))))
          records))))

(define (font-records directory cache revision)
  "Inspect the faces in DIRECTORY using CACHE entries for inspection REVISION."
  (let ((files (filter font-file?
                       (files-under (string-append directory "/share/fonts"))))
        (record-cache (string-append cache "/font-records/" revision))
        (seen (make-hash-table)))
    (when (null? files)
      (error "No font files" directory))
    (sort
     (append-map
      (lambda (path)
        (let ((digest (file-digest path)))
          (if (hash-ref seen digest)
              '()
              (begin
                (hash-set! seen digest #t)
                (cached-font-records path digest record-cache)))))
      files)
     face<?)))
