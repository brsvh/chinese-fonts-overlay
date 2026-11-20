(define-module (chinese-fonts-overlay-site previews)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (chinese-fonts-overlay-site samples)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 threads)
  #:use-module (json)
  #:use-module ((rnrs unicode) #:select (string-foldcase))
  #:use-module (srfi srfi-1)
  #:export (validate-image
            render-jobs
            prepare-previews
            font-file?))

(define (font-file? path)
  "Recognize supported original font file suffixes without case sensitivity."
  (any (lambda (suffix) (string-suffix? suffix (string-downcase path)))
       '(".ttf" ".otf" ".ttc" ".otc")))

(define (native-tool variable name)
  "Resolve the configured native tool or locate NAME on PATH."
  (or (getenv variable)
      (search-path (string-split (or (getenv "PATH") "") #\:) name)
      (error "Native font tool not found" name)))

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
  (let ((cache-file
         (and cache
              (string-append cache "/v3-" digest "-"
                             (force sample-revision) ".json"))))
    (if (and cache-file (file-exists? cache-file))
        (map (lambda (record) (jset record "file" path))
             (jarray (read-json cache-file)))
        (let ((records
               (append-map (lambda (face) (face-records face digest path))
                           (inspect "inspect" path))))
          (when cache-file
            (atomic-write
             cache-file
             (lambda (file)
               (write-json
                file
                (list->vector
                 (map (lambda (record) (alist-delete "file" record equal?))
                      records))))))
          records))))

(define* (font-records directory #:optional cache)
  "Inspect all faces in DIRECTORY, optionally reusing content-keyed CACHE."
  (let ((files (filter font-file?
                       (files-under (string-append directory "/share/fonts"))))
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
                (cached-font-records path digest cache)))))
      files)
     face<?)))

(define (render-jobs jobs)
  "Render tab-separated JOBS and record unsupported samples; raise on failure."
  (unless (null? jobs)
    (let* ((port (mkstemp
                  (string-append
                   (or (getenv "TMPDIR") "/tmp")
                   "/font-site-jobs-XXXXXX")))
           (file (port-filename port))
           (outputs (map last jobs)))
      (dynamic-wind
        (lambda () (set-port-encoding! port "UTF-8"))
        (lambda ()
          (for-each
           (lambda (fields)
             (when (any (lambda (field)
                          (string-any (char-set #\tab #\newline #\return)
                                      field))
                        fields)
               (error "Unexpected tab/newline in sample metadata"))
             (display (string-join fields "\t") port)
             (newline port))
           jobs)
          (close-port port)
          (for-each
           (lambda (line)
             (unless (string-null? line)
               (match (string-split line #\tab)
                 (("skip" path)
                  (unless (member path outputs)
                    (error "Unexpected renderer output path" path))
                  (write-text (string-append path ".unsupported") ""))
                 (_ (error "Unexpected renderer result" line)))))
           (string-split
            (capture
             (native-tool "FONT_SITE_RENDERER" "render-font-samples")
             file)
            #\newline))
          (for-each
           (lambda (path)
             (unless (or (file-exists? path)
                         (file-exists? (string-append path ".unsupported")))
               (error "Renderer produced no result" path)))
           outputs))
        (lambda ()
          (unless (port-closed? port)
            (close-port port))
          (when (file-exists? file)
            (delete-file file)))))))

(define (package-languages package record)
  "Select package languages applicable to RECORD, including symbol samples."
  (let ((tags (catalog-languages (jarray (jref package "languages")))))
    (if (and (not (any (lambda (tag) (assoc tag (jref record "samples"))) tags))
             (assoc "unknown" (jref record "samples")))
        (append tags '("unknown"))
        tags)))

(define (stage-image source digest staging previous)
  "Link an intact prior image or copy SOURCE with DIGEST into STAGING."
  (let* ((relative (string-append "images/" digest ".webp"))
         (target (string-append staging "/" relative))
         (old (string-append previous "/assets/" relative)))
    (unless (file-exists? target)
      (mkdir-p (dirname target))
      (if (and (file-exists? old) (string=? digest (file-digest old)))
          (catch 'system-error
                 (lambda () (link old target))
                 (lambda _ (copy-file source target)))
          (copy-file source target)))))

(define (collect-image! record tag image-cache images jobs)
  "Register one face/language image and enqueue uncached rendering work."
  (let ((index (jref (jref record "samples") tag)))
    (when index
      (let* ((choice (list-ref (candidates tag) index))
             (text (car choice))
             (key (list (jref record "key") tag index))
             (identity
              (string-append
               "["
               (string-join
                (map scm->json-string (list (jref record "key") tag text))
                ", ")
               "]"))
             (digest (text-digest identity))
             (path (string-append
                    image-cache
                    "/"
                    (substring digest 0 2)
                    "/"
                    digest
                    ".webp")))
        (unless (hash-ref images key)
          (hash-set! images key (list path text (cdr choice)))
          (unless (or (file-exists? path)
                      (file-exists? (string-append path ".unsupported")))
            (mkdir-p (dirname path))
            (let* ((coordinates (jref record "variations"))
                   (variations
                    (if (null? coordinates)
                        "-"
                        (string-join
                         (map (lambda (entry)
                                (format #f "~a=~a" (car entry) (cdr entry)))
                              coordinates)
                         ",")))
                   (job (list (jref record "file")
                              (number->string (jref record "index"))
                              variations
                              tag
                              text
                              path)))
              (hash-set!
               jobs
               (jref record "key")
               (cons job (hash-ref jobs (jref record "key") '()))))))))))

(define (render-batches jobs images)
  "Render JOBS with at most four subprocesses and propagate worker failures."
  (let ((batches (make-vector 4 '()))
        (groups
         (sort (hash-map->list (lambda (key value) value) jobs)
               (lambda (a b) (> (length a) (length b))))))
    (for-each
     (lambda (group)
       (let* ((indexes (list 0 1 2 3))
              (index (car (sort indexes
                                (lambda (a b)
                                  (< (length (vector-ref batches a))
                                     (length (vector-ref batches b))))))))
         (vector-set! batches index (append group (vector-ref batches index)))))
     groups)
    (format
     #t
     "Rendering ~a new samples for ~a face/language combinations.~%"
     (apply + (map length (vector->list batches)))
     (hash-count (const #t) images))
    (force-output)
    ;; n-par-map joins workers but does not propagate their exceptions.
    (for-each
     (lambda (failure) (when failure (apply throw failure)))
     (n-par-map
      4
      (lambda (batch)
        (catch #t
               (lambda () (render-jobs batch) #f)
               (lambda failure failure)))
      (vector->list batches)))))

(define (verified-images destination)
  "Index previously published content hashes and their pixel dimensions."
  (let ((previous (string-append destination "/previews.json"))
        (verified (make-hash-table)))
    (when (file-exists? previous)
      (for-each
       (lambda (entry)
         (for-each
          (lambda (face)
            (for-each
             (lambda (sample)
               (let ((value (cdr sample)))
                 (hash-set!
                  verified
                  (jref value "url")
                  (vector (jref value "width") (jref value "height")))))
             (jref face "samples")))
          (jarray (jref (cdr entry) "faces"))))
       (read-json previous)))
    verified))

(define (publish-images images verified destination staging)
  "Validate and stage cached images, returning their public metadata."
  (let ((public (make-hash-table)))
    (hash-for-each
     (lambda (key value)
       (match value
         ((path text kind)
          (when (file-exists? path)
            (let* ((digest (file-digest path))
                   (url (string-append "assets/images/" digest ".webp"))
                   (size (if (and (hash-ref verified url)
                                  (file-exists?
                                   (string-append destination "/" url)))
                             (hash-ref verified url)
                             (validate-image path))))
              (stage-image path digest staging destination)
              (hash-set!
               public
               key
               `(("url" . ,url)
                 ("width" . ,(vector-ref size 0))
                 ("height" . ,(vector-ref size 1))
                 ("text" . ,text)
                 ("kind" . ,kind))))))))
     images)
    public))

(define (face-preview package record public)
  "Build the public language image map for one font RECORD."
  (let ((available
         (filter-map
          (lambda (tag)
            (let* ((index (jref (jref record "samples") tag))
                   (image (and index
                               (hash-ref
                                public
                                (list (jref record "key") tag index)))))
              (and image (cons tag image))))
          (package-languages package record))))
    `(("name" . ,(jref record "name"))
      ("family" . ,(jref record "family"))
      ("weight" . ,(let ((weight (jref record "weight")))
                     (if (integer? weight) (inexact->exact weight) weight)))
      ("style" . ,(jref record "style"))
      ("samples" . ,available)
      ("defaultLanguage" . ,(default-language available)))))

(define (prepare-previews catalog selected cache staging previous-output)
  "Write previews into owned STAGING, reusing CACHE and PREVIOUS-OUTPUT.
The caller publishes or discards STAGING as part of the complete site build."
  (let* ((packages (jarray (jref catalog "packages")))
         (identifiers (map (lambda (package) (jref package "id")) packages))
         (records (make-hash-table))
         (images (make-hash-table))
         (jobs (make-hash-table))
         (inspector-id
          (file-digest (native-tool "FONT_SITE_INSPECTOR" "font-info")))
         (renderer (native-tool "FONT_SITE_RENDERER" "render-font-samples"))
         (renderer-id
          (text-digest (string-append (file-digest renderer) ":"
                                     (capture renderer "--encoder-version"))))
         (record-cache (string-append cache "/font-records/" inspector-id))
         (image-cache (string-append cache "/language-images/" renderer-id)))
    (unless (equal? (sort (map car selected) string<?)
                    (sort identifiers string<?))
      (error "Preview selection must match the complete catalog"))
    (for-each
     (lambda (entry)
       (unless (and (equal? (map car (cdr entry)) '("renderPath"))
                    (string? (jref (cdr entry) "renderPath")))
         (error "Font must only have a local renderer path" (car entry))))
     selected)
    (for-each
     (lambda (package)
       (for-each
        (lambda (tag)
          (unless (assoc tag (force samples))
            (error "Missing language samples" tag)))
        (jarray (jref package "languages"))))
     packages)
    (mkdir-p (string-append staging "/assets"))
    (for-each
     (lambda (package)
       (let* ((id (jref package "id"))
              (faces (font-records
                      (jref (jref selected id) "renderPath")
                      record-cache)))
         (hash-set! records id faces)
         (for-each
          (lambda (record)
            (for-each
             (lambda (tag) (collect-image! record tag image-cache images jobs))
             (package-languages package record)))
          faces)))
     packages)
    (render-batches jobs images)
    (let* ((public (publish-images images
                                   (verified-images previous-output)
                                   previous-output
                                   (string-append staging "/assets")))
           (result
            (map (lambda (package)
                   (let ((id (jref package "id")))
                     (cons id
                           `(("kind" . "image")
                             ("faces" .
                              ,(list->vector
                                (map (lambda (record)
                                       (face-preview package record public))
                                     (hash-ref records id))))))))
                 packages)))
      (write-json (string-append staging "/previews.json") result)
      (format #t "Prepared all ~a packages with ~a language samples.~%"
              (length packages) (hash-count (const #t) public)))))
