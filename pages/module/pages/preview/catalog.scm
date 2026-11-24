(define-module (chinese-fonts-overlay pages preview catalog)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (chinese-fonts-overlay pages preview samples)
  #:use-module ((chinese-fonts-overlay pages presentation layout)
                #:select (source-repository))
  #:use-module (json)
  #:use-module (srfi srfi-1)
  #:use-module (web uri)
  #:export (index-preview-manifests! write-public-catalog!))

(define (merge object fields)
  "Return OBJECT extended with the public FIELDS."
  (fold (lambda (entry result) (jset result (car entry) (cdr entry)))
        object
        fields))

(define (license-categories licenses)
  "Retain explicit free and proprietary choices, without classifying unknowns."
  (delete-duplicates
   (map (lambda (license)
          (let ((free (jref license "free" 'null)))
            (cond
             ((eq? free #t) "open")
             ((eq? free #f) "proprietary")
             (else "unknown"))))
        (if (null? licenses) '(()) licenses))))

(define (write-face-manifest! face destination)
  "Write one public face manifest and attach its content-addressed URL."
  (let* ((content (scm->json-string `(("samples" . ,(jref face "samples")))))
         (name (string-append "assets/previews/" (text-digest content) ".json")))
    (let ((path (string-append destination "/" name)))
      (unless (file-exists? path) (write-text path content)))
    (jset face "manifest" name)))

(define (cover-face name faces)
  "Choose the closest regular face for each language, without changing samples."
  (define (rank face)
    (+ (abs (- (jref face "weight" 400) 400))
       (if (equal? (jref face "style") "normal") 0 1000)))
  (let ((samples
         (fold (lambda (face samples)
                 (fold (lambda (entry result)
                         (if (assoc (car entry) result)
                             result
                             (append result (list entry))))
                       samples
                       (jref face "samples")))
               '()
               (stable-sort faces (lambda (a b) (< (rank a) (rank b)))))))
    `(("name" . ,name)
      ("samples" . ,samples)
      ("defaultLanguage" . ,(default-language samples)))))

(define (catalog-entry package catalog faces cover revision)
  "Join reviewed package facts, previews and a permanent source URL."
  (let* ((source (jref package "source"))
         (path (string-join
                (map uri-encode (string-split (jref source "path") #\/))
                "/")))
    (merge package
           `(("preview"
              ("kind" . "image")
              ("faces" . ,(list->vector faces)))
             ("cover" . ,cover)
             ("licenseCategories"
              . ,(list->vector
                  (license-categories (jarray (jref package "licenses")))))
             ("source" . ,(jset source
                                "url"
                                (string-append
                                 source-repository
                                 "/blob/"
                                 revision
                                 "/"
                                 path)))
             ("licenseCostName" . ,(jref (jref catalog "licenseCostLabels")
                                         (jref package "licenseCost")))
             ("languageNames"
              . ,(list->vector
                  (map language-label (jarray (jref package "languages")))))
             ("styleNames"
              . ,(list->vector
                  (map (lambda (style)
                         (jref (jref catalog "styleLabels") style))
                       (jarray (jref package "styles")))))))))

(define (public-package package)
  "Remove inline image maps while retaining public face metadata."
  (define (without-samples face)
    (remove (lambda (entry) (equal? (car entry) "samples")) face))
  (merge package
         `(("cover" . ,(without-samples (jref package "cover")))
           ("preview"
            ("kind" . "image")
            ("faces" . ,(list->vector
                         (map
                          without-samples
                          (jarray (jref (jref package "preview") "faces")))))))))

(define (index-preview-manifests! catalog rendered-previews destination revision)
  "Write face manifests and return the catalog with samples for page rendering."
  (let ((raw (jarray (jref catalog "packages"))))
    (unless (equal? (sort (map car rendered-previews) string<?)
                    (sort (map (lambda (p) (jref p "id")) raw) string<?))
      (error "Expected previews for every font package"))
    (mkdir-p (string-append destination "/assets/previews"))
    (let* ((packages
            (map (lambda (package)
                   (let* ((preview (jref rendered-previews (jref package "id")))
                          (faces (jarray (jref preview "faces")))
                          (cover (cover-face (jref package "displayName") faces)))
                     (catalog-entry package catalog
                                    (map (lambda (face)
                                           (write-face-manifest! face destination))
                                         faces)
                                    (write-face-manifest! cover destination)
                                    revision)))
                 raw))
           (languages
            (prioritize-entries
             '("zh-cn" "en" "zh-tw" "zh-hk" "ja" "ko")
             (map (lambda (key) (cons key (language-label key)))
                  (sort (delete-duplicates
                         (append-map
                          (lambda (p)
                            (catalog-languages (jarray (jref p "languages"))))
                          packages))
                        string<?)))))
      (merge catalog
             `(("schema" . 5)
               ("sourceRepository" . ,source-repository)
               ("sourceRevision" . ,revision)
               ("languageLabels" . ,languages)
               ("packages" . ,(list->vector packages)))))))

(define (write-public-catalog! catalog destination)
  "Write public metadata with links to the separately stored face manifests."
  (write-json (string-append destination "/catalog.json")
              (jset catalog "packages"
                    (list->vector (map public-package
                                       (jarray (jref catalog "packages")))))))
