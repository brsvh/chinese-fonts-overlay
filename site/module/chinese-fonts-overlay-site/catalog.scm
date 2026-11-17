(define-module (chinese-fonts-overlay-site catalog)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (chinese-fonts-overlay-site samples)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (sxml simple)
  #:use-module (srfi srfi-1)
  #:use-module (web uri)
  #:export (render-catalog))

(define source-repository "https://github.com/brsvh/chinese-fonts-overlay")

(define (xml tree)
  "Serialize SXML TREE with text and attribute escaping."
  (call-with-output-string (lambda (port) (sxml->xml tree port))))

(define (encode text)
  "Percent-encode one URL path segment or filter token."
  (uri-encode
   text
   #:unescaped-chars
   (char-set-union char-set:letter+digit (string->char-set "-_.~"))))

(define (link url label)
  "Return an HTTP(S) link, or plain LABEL for an unsupported URL."
  (if (and (string? url)
           (or (string-prefix? "http://" url) (string-prefix? "https://" url)))
      `(a (@ (href ,url)) ,label)
      label))

(define (merge object fields)
  "Return OBJECT extended with the public FIELDS."
  (fold (lambda (entry result) (jset result (car entry) (cdr entry)))
        object
        fields))

(define (join-names values)
  "Join Chinese display names, using the unknown label for an empty list."
  (if (null? values) "未知" (string-join values "、")))

(define (license-html license)
  "Render a license name, SPDX identifier and optional reference link."
  (let ((name (jref license "name")) (spdx (jref license "spdxId")))
    (link (jref license "url")
          (if (and (string? spdx) (not (equal? spdx name)))
              (string-append name " (" spdx ")")
              name))))

(define (preview-html package)
  "Render every preview face with its static image and enhancement hooks."
  `(div
    (h4 "字体预览")
    (ul ,@(map
           (lambda (face)
             (let* ((samples (jref face "samples"))
                    (tag (jref face "defaultLanguage"))
                    (sample (jref samples tag))
                    (name (jref face "name")))
               `(li
                 (@ (data-image-preview "")
                    (data-samples-url ,(jref face "manifest"))
                    (data-face-name ,name))
                 (p ,name)
                 (p (@ (data-preview-status "")
                       (role "status")
                       ,@(if sample '((hidden "hidden")) '()))
                    ,(if sample "" "此款式暂无预览。"))
                 (span
                  (@ (data-preview-slot ""))
                  ,@(if sample
                        `((img
                           (@ (src ,(jref sample "url"))
                              (alt ,(string-append
                                     name
                                     "："
                                     (language-label tag)
                                     (if (equal?
                                          (jref sample "kind")
                                          "characters")
                                         "字表预览"
                                         "预览")))
                              (width ,(jref sample "width"))
                              (height ,(jref sample "height"))
                              (loading "lazy")
                              (style "max-width: 100%; height: auto"))))
                        '("")))
                 (button
                  (@ (data-preview-retry "")
                     (type "button")
                     (hidden "hidden"))
                  "重试加载"))))
           (jarray (jref (jref package "preview") "faces"))))))

(define (notices-html notices)
  "Render optional plain-text notices without collapsing or interpreting HTML."
  (if (null? notices)
      '()
      `((section
         (@ (aria-label "注意事项"))
         (h4 "注意事项")
         (ul ,@(map (lambda (notice)
                      `(li (@ (data-notice-level ,(jref notice "level")))
                           (p (strong ,(jref notice "levelName")))
                           (p (@ (style "white-space: pre-wrap"))
                              ,(jref notice "text"))
                           ,@(if (jref notice "url")
                                 `((p ,(link (jref notice "url") "参考来源")))
                                 '())))
                    notices))))))

(define (package-html package)
  "Render one public PACKAGE with metadata, notices and every preview face."
  (let* ((p (lambda (key) (jref package key)))
         (licenses (jarray (p "licenses")))
         (faces (jarray (p "faces")))
         (search
          (append
           (list (p "pname")
                 (p "attribute")
                 (p "description")
                 (p "vendor")
                 (p "vendorName")
                 (p "licenseCostName"))
           (jarray (p "languages"))
           (jarray (p "languageNames"))
           (jarray (p "styleNames"))
           faces
           (map (lambda (license) (jref license "name")) licenses)
           (map (lambda (license)
                  (let ((id (jref license "spdxId"))) (if (string? id) id "")))
                licenses))))
    (xml `(li (@ (id ,(p "id"))
                 (data-search ,(string-join search " "))
                 (data-vendor ,(p "vendor"))
                 (data-license-cost ,(p "licenseCost"))
                 (data-licenses
                  ,(string-join
                    (map (lambda (license) (encode (jref license "id")))
                         licenses)
                    " "))
                 (data-languages
                  ,(string-join
                    (filter-languages (jarray (p "languages")))
                    " "))
                 (data-styles
                  ,(string-join
                    (if (zero? (vector-length (p "styles")))
                        '("unknown")
                        (jarray (p "styles")))
                    " "))
                 (data-redistributable
                  ,(if (p "redistributable") "true" "false")))
              (article
               (h3 (code ,(p "pname")))
               (p ,(p "description"))
               (dl (dt "包名")
                   (dd (code ,(p "attribute")))
                   (dt "版本")
                   (dd ,(if (string-null? (p "version")) "未知" (p "version")))
                   (dt "字库")
                   (dd ,(p "vendorName"))
                   (dt "许可证费用")
                   (dd ,(p "licenseCostName"))
                   (dt "许可证")
                   (dd ,@(if (null? licenses)
                             '("未知")
                             (append-map
                              (lambda (item)
                                (if (eq? item (car licenses))
                                    (list (license-html item))
                                    (list "；" (license-html item))))
                              licenses)))
                   (dt "再分发")
                   (dd ,(if (p "redistributable") "允许" "不允许"))
                   (dt "语言")
                   (dd ,(join-names (jarray (p "languageNames"))))
                   (dt "风格")
                   (dd ,(join-names (jarray (p "styleNames")))))
               (p (a (@ (href ,(jref (p "source") "url"))) "source")
                  ,@(append-map
                     (lambda (url) (list " · " (link url "主页")))
                     (jarray (p "homepages"))))
               ,@(notices-html (jarray (p "notices")))
               ,@(if (null? faces)
                     '((p "字重／款式：未知。"))
                     `((h4 ,(format #f "字重／款式（~a 款）" (length faces)))
                       (ul ,@(map (lambda (name) `(li ,name)) faces))))
               ,(preview-html package)
               ,@(if (string-null? (p "longDescription"))
                     '()
                     `((h4 "详细说明")
                       (p (@ (style "white-space: pre-wrap"))
                          ,(p "longDescription")))))))))

(define* (option value label #:optional selected)
  "Render a select option with VALUE, LABEL and optional selection."
  (xml `(option
         (@ (value ,value) ,@(if selected '((selected "selected")) '()))
         ,label)))

(define (write-face-manifests preview destination)
  "Write per-face manifests and add their URLs to PREVIEW metadata."
  (let ((faces (map (lambda (face)
                      (let* ((content
                              (json-string
                               `(("samples" . ,(jref face "samples"))
                                 ("defaultLanguage" .
                                  ,(jref face "defaultLanguage")))))
                             (name (string-append
                                    "assets/previews/"
                                    (text-digest content)
                                    ".json")))
                        (write-text
                         (string-append destination "/" name)
                         content)
                        (jset face "manifest" name)))
                    (jarray (jref preview "faces")))))
    (jset preview "faces" (list->vector faces))))

(define (augment-package package catalog previews revision destination)
  "Join package facts, reviewed labels, previews and a permanent source URL."
  (let* ((preview
          (write-face-manifests (jref previews (jref package "id"))
                                destination))
         (source (jref package "source"))
         (path (string-join
                (map encode (string-split (jref source "path") #\/))
                "/")))
    (merge package
           `(("preview" . ,preview)
             ("source" .
              ,(jset source
                     "url"
                     (string-append
                      source-repository
                      "/blob/"
                      revision
                      "/"
                      path)))
             ("faces" .
              ,(list->vector
                (map (lambda (face) (jref face "name"))
                     (jarray (jref preview "faces")))))
             ("licenseCostName" .
              ,(jref (jref catalog "licenseCostLabels")
                     (jref package "licenseCost")))
             ("languageNames" .
              ,(list->vector
                (map language-label (jarray (jref package "languages")))))
             ("styleNames" .
              ,(list->vector
                (map (lambda (style) (jref (jref catalog "styleLabels") style))
                     (jarray (jref package "styles")))))
             ("notices" .
              ,(list->vector
                (map (lambda (notice)
                       (jset notice
                             "levelName"
                             (jref (jref catalog "noticeLevelLabels")
                                   (jref notice "level"))))
                     (jarray (jref package "notices" #())))))))))

(define (render-catalog catalog destination revision)
  "Write the static catalog for REVISION, rejecting incomplete metadata."
  (unless (string-match "^[0-9a-f]{40}$" revision)
    (error "Expected a full Git commit SHA for source permalinks" revision))
  (let* ((previews (read-json (string-append destination "/previews.json")))
         (raw (jarray (jref catalog "packages"))))
    (unless (equal?
             (sort (map car previews) string<?)
             (sort (map (lambda (package) (jref package "id")) raw) string<?))
      (error "Expected previews for every font package"))
    (mkdir-p (string-append destination "/assets/previews"))
    (let* ((packages
            (map (lambda (package)
                   (augment-package
                    package
                    catalog
                    previews
                    revision
                    destination))
                 raw))
           (vendors
            (sort (unique
                   (map (lambda (package) (jref package "vendor")) packages))
                  string<?))
           (languages
            (sort (unique
                   (append-map
                    (lambda (package) (jarray (jref package "languages")))
                    packages))
                  string<?))
           (licenses
            (delete-duplicates
             (append-map
              (lambda (package) (jarray (jref package "licenses")))
              packages)
             (lambda (a b) (equal? (jref a "id") (jref b "id")))))
           (labels
            (append
             (map (lambda (tag) (cons tag (language-label tag))) languages)
             '(("zh" . "中文") ("unknown" . "未知"))))
           (substitutions
            `(("<!-- license-cost-options -->" .
               ,(string-concatenate
                 (map (lambda (key)
                        (option
                         key
                         (jref (jref catalog "licenseCostLabels") key)))
                      '("none" "commercialFree" "personalFree" "paid"))))
              ("<!-- license-options -->" .
               ,(string-concatenate
                 (map (lambda (license)
                        (option
                         (encode (jref license "id"))
                         (jref license "name")))
                      (sort licenses
                            (lambda (a b)
                              (string<? (jref a "id") (jref b "id")))))))
              ("<!-- vendor-options -->" .
               ,(string-concatenate
                 (map (lambda (vendor)
                        (option
                         vendor
                         (jref (jref catalog "vendors") vendor "未知")))
                      vendors)))
              ("<!-- language-options -->" .
               ,(string-append
                 (option "zh" "中文" #t)
                 (string-concatenate
                  (map (lambda (tag) (option tag (language-label tag)))
                       languages))
                 (if (any (lambda (package)
                            (zero? (vector-length (jref package "languages"))))
                          packages)
                     (option "unknown" "未知")
                     "")))
              ("<!-- style-options -->" .
               ,(string-concatenate
                 (map (lambda (entry) (option (car entry) (cdr entry)))
                      (jref catalog "styleLabels"))))
              ("<!-- count -->" . ,(number->string (length packages)))
              ("<!-- language-labels -->" .
               ,(string-replace-substring (json-string labels) "<" "\\u003c"))
              ("<!-- packages -->" .
               ,(string-join (map package-html packages) "\n"))))
           (page (fold (lambda (entry text)
                         (string-replace-substring
                          text
                          (car entry)
                          (cdr entry)))
                       (read-text (web-file "index.html"))
                       substitutions))
           (public
            (map (lambda (package)
                   (jset package
                         "preview"
                         `(("kind" . "image")
                           ("faces" .
                            ,(list->vector
                              (map (lambda (face)
                                     (filter
                                      (lambda (entry)
                                        (member
                                         (car entry)
                                         '("name" "manifest"
                                           "defaultLanguage")))
                                      face))
                                   (jarray
                                    (jref (jref package "preview")
                                          "faces"))))))))
                 packages))
           (result
            (merge catalog
                   `(("sourceRepository" . ,source-repository)
                     ("sourceRevision" . ,revision)
                     ("facesSource" .
                      ,(string-append
                        "packaged font files, collection members "
                        "and named variable instances"))
                     ("schema" . 4)
                     ("languageLabels" . ,labels)
                     ("packages" . ,(list->vector public))))))
      (write-text (string-append destination "/index.html") page)
      (write-json (string-append destination "/catalog.json") result)
      (format
       #t
       "Rendered ~a font packages with source permalinks at ~a.~%"
       (length packages)
       revision))))
