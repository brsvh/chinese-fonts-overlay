(define-module (chinese-fonts-overlay-site catalog)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (chinese-fonts-overlay-site samples)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (json)
  #:use-module (sxml simple)
  #:use-module (srfi srfi-1)
  #:use-module (web uri)
  #:export (render-catalog))

(define source-repository "https://github.com/brsvh/chinese-fonts-overlay")

(define (xml tree)
  "Serialize HTML from SXML, retaining explicit closing tags for nonvoid nodes."
  (call-with-output-string (lambda (port) (sxml->xml tree port))))

(define (http-url? url)
  "Accept only HTTP(S) destinations for public reference links."
  (and (string? url)
       (or (string-prefix? "http://" url) (string-prefix? "https://" url))))

(define (link url label)
  "Return an HTTP(S) link, or plain LABEL for an unsupported URL."
  (if (http-url? url) `(a (@ (href ,url)) ,label) label))

(define (icon name)
  "Reference a decorative symbol from the page's inline icon sheet."
  `(svg (@ (aria-hidden "true") (viewBox "0 0 24 24"))
        (use (@ (href ,(string-append "#icon-" name))) "")))

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

(define (preview-html face cover?)
  "Render a face's default sample and hooks for language-specific enhancement."
  (let* ((tag (jref face "defaultLanguage"))
         (sample (jref (jref face "samples") tag))
         (name (jref face "name")))
    `(section
      (@ (class ,(if cover? "cover-preview" "face-item"))
         (data-image-preview ,(if cover? "cover" "face"))
         (data-samples-url ,(jref face "manifest"))
         (data-face-name ,name))
      ,@(if cover? '() `((h3 (@ (class "face-caption")) ,name)))
      (p (@ (class "preview-status")
            (data-preview-status "")
            (role "status")
            ,@(if sample '((hidden "hidden")) '()))
         ,(if sample " " "此款式暂无预览。"))
      (div (@ (data-preview-slot ""))
           ,@(if sample
                 `((div (@ (class "sample")
                           (tabindex "0")
                           (role "region")
                           (aria-label "字体预览，可横向滚动"))
                        (img (@ (src ,(jref sample "url"))
                                (alt ,(string-append
                                       name
                                       "："
                                       (language-label tag)
                                       "，"
                                       (jref sample "text")))
                                (width ,(jref sample "width"))
                                (height ,(jref sample "height"))
                                (loading "lazy")))))
                 '(" ")))
      (button
       (@ (class "btn btn-ghost btn-xs")
          (data-preview-retry "")
          (type "button")
          (hidden "hidden"))
       "重试加载"))))

(define (notices-html notices level-labels)
  "Render visible plain-text notices with localized levels and source links."
  (if (null? notices)
      '()
      `((section
         (@ (class "package-notices") (aria-label "注意事项"))
         ,@(map (lambda (notice)
                  `(div (@ (class "alert package-notice")
                           (data-notice-level ,(jref notice "level")))
                        (h3 (@ (class "notice-heading"))
                            ,(icon "notice")
                            ,(jref level-labels (jref notice "level") "注意事项"))
                        (p (@ (class "notice-text")) ,(jref notice "text"))
                        ,@(if (http-url? (jref notice "url"))
                              `((p (@ (class "notice-source"))
                                   ,(link (jref notice "url") "查看原文")))
                              '())))
                notices)))))

(define (homepage-control name homepages)
  "Render direct or disclosed upstream links in their reviewed source order."
  (let* ((urls (filter http-url? (jarray homepages)))
         (label (string-append name " 上游主页")))
    (cond
     ((null? urls) "")
     ((null? (cdr urls))
      `(a (@ (class "upstream")
             (href ,(car urls))
             (aria-label ,label)
             (title ,(car urls)))
          ,(icon "arrow")))
     (else
      `(details
        (@ (class "dropdown upstream-menu"))
        (summary (@ (class "upstream upstream-toggle")
                    (aria-label ,(format #f "~a（~a 个）" label (length urls)))
                    (title "选择上游主页"))
                 ,(icon "arrow")
                 (span ,(number->string (length urls)))
                 ,(icon "down"))
        (ul (@ (class "dropdown-content menu upstream-links")
               (aria-label ,label))
            ,@(map (lambda (url)
                     `(li (a (@ (href ,url)) (span ,url) ,(icon "arrow"))))
                   urls)))))))

(define (package-html package notice-level-labels)
  "Render a package with localized notices, font disclosures and source links."
  (let* ((p (lambda (key) (jref package key)))
         (faces (jarray (jref (p "preview") "faces")))
         (licenses (jarray (p "licenses")))
         (version (if (string-null? (p "version")) "未知" (p "version")))
         (search
          (append
           (list (p "displayName")
                 (p "pname")
                 (p "attribute")
                 (p "description")
                 (p "vendorName"))
           (jarray (p "languageNames"))
           (jarray (p "styleNames"))
           (map (lambda (face) (jref face "name")) faces))))
    (xml `(article
           (@ (class "font-row")
              (id ,(p "id"))
              (data-search ,(string-join search " "))
              (data-name ,(p "displayName"))
              (data-vendor ,(p "vendor"))
              (data-cost ,(p "licenseCost"))
              (data-license
               ,(string-join (jarray (p "licenseCategories")) " "))
              (data-language
               ,(string-join (catalog-languages (jarray (p "languages"))) " "))
              (data-style ,(string-join (jarray (p "styles")) " "))
              (data-embedding ,(if (p "embedding") "true" "false")))
           (div (@ (class "row-top"))
                (div (@ (class "font-title"))
                     (h2 (@ (class "font-name")) ,(p "displayName"))
                     ,(homepage-control (p "displayName") (p "homepages")))
                (span (@ (class "vendor")) ,(p "vendorName")))
           (details
            (@ (class "face-list"))
            (summary ,(format #f "~a 款字体" (length faces)) ,(icon "down"))
            ,@(map (lambda (face) (preview-html face #f)) faces))
           ,(preview-html (p "cover") #t)
           (div (@ (class "row-bottom"))
                (button
                 (@ (class "btn btn-ghost btn-xs copy-package")
                    (type "button")
                    (data-copy ,(p "attribute"))
                    (data-interactive "")
                    (disabled "disabled")
                    (aria-label ,(string-append "复制 " (p "attribute")))
                    (title "复制完整包名"))
                 (code ,(p "attribute"))
                 ,(icon "copy"))
                (div (@ (class "licenses"))
                     (span (@ (class "badge badge-ghost package-version"))
                           ,version)
                     (span (@ (class ,(if (member (p "licenseCost")
                                                  '("none" "commercialFree"))
                                          "badge badge-soft badge-success cost"
                                          "badge badge-soft badge-warning cost cost-restricted")))
                           ,(p "licenseCostName"))
                     ,@(map (lambda (license)
                              `(span (@ (class "license"))
                                     ,(link (jref license "url")
                                            (let ((spdx (jref license "spdxId")))
                                              (if (string? spdx)
                                                  spdx
                                                  (jref license "name"))))))
                            licenses)
                     (span (@ (class ,(if (p "redistributable")
                                          "redistribution"
                                          "redistribution restricted")))
                           ,(icon (if (p "redistributable") "check" "lock"))
                           ,(if (p "redistributable") "可再分发" "再分发受限")))
                (a (@ (class "source") (href ,(jref (p "source") "url")))
                   "源代码 "
                   ,(icon "arrow")))
           ,@(notices-html (jarray (p "notices")) notice-level-labels)
           (details
            (@ (class "package-info"))
            (summary (@ (class "info-toggle"))
                     (span (@ (class "info-show")) "显示字体信息")
                     (span (@ (class "info-hide")) "隐藏字体信息")
                     ,(icon "down"))
            (dl (@ (class "package-metadata"))
                (dt "字体介绍：")
                (dd ,(p "description"))
                (dt "字体详细介绍：")
                (dd (@ (class "notice-text"))
                    ,(if (string-null? (p "longDescription"))
                         "暂无详细介绍。"
                         (p "longDescription")))
                (dt "版本：")
                (dd ,version)
                (dt "风格：")
                (dd ,(string-join (jarray (p "styleNames")) "、"))
                (dt "支持语言：")
                (dd ,(string-join (jarray (p "languageNames")) "、"))))))))

(define (facet-label-content text)
  "Prefer wrapping between names and qualifiers when each fits the option."
  (let ((group (string-match
                (string-append "（[^（）]*）|\\([^()]*\\)|「[^「」]*」|"
                               "『[^『』]*』|【[^【】]*】|《[^《》]*》")
                text)))
    (if group
        (append
         (if (string-null? (match:prefix group))
             '()
             `((span (@ (class "facet-phrase")) ,(match:prefix group))))
         `((span (@ (class "facet-phrase")) ,(match:substring group)))
         (facet-label-content (match:suffix group)))
        (list text))))

(define (facet-html key title labels defaults limit chips?)
  "Render a multiselect facet with select-all and collapsible additional choices."
  (define (choice entry)
    (let ((id (string-append key "-" (car entry))))
      `(label (@ (class ,(if chips? "facet-chip" "check-option")) (for ,id))
              (input (@ (id ,id)
                        (type "checkbox")
                        (value ,(car entry))
                        (class "checkbox checkbox-primary checkbox-xs")
                        (data-choice ,key)
                        ,@(if (member (car entry) defaults)
                              '((checked "checked"))
                              '())))
              (span ,@(facet-label-content (cdr entry))))))
  (xml `(fieldset
         (@ (class "facet")
            (id ,key)
            (data-facet ,key)
            (data-default ,(string-join defaults ","))
            (data-interactive "")
            (disabled "disabled"))
         (legend ,title)
         (label (@ (class "facet-all"))
                (input (@ (type "checkbox")
                          (class "checkbox checkbox-primary checkbox-xs")
                          (data-select-all ,key)
                          (aria-label ,(string-append "全选" title))
                          ,@(if (= (length defaults) (length labels))
                                '((checked "checked"))
                                '())))
                "全选")
         (div (@ (class ,(if chips? "facet-options" "check-options")))
              ,@(map choice (take labels (min limit (length labels))))
              ,@(if (> (length labels) limit)
                    `((div (@ (class "facet-extra")
                              (id ,(string-append key "-extra"))
                              (hidden "hidden"))
                           ,@(map choice (drop labels limit))))
                    '()))
         ,@(if (> (length labels) limit)
               `((button
                  (@ (class "btn btn-ghost btn-xs facet-toggle")
                     (type "button")
                     (data-facet-toggle ,key)
                     (aria-expanded "false")
                     (aria-controls ,(string-append key "-extra")))
                  (span "展开")
                  ,(icon "down")))
               '()))))

(define (prioritize keys entries)
  "Place present KEYS first, retaining the remaining entries' stable order."
  (append
   (filter-map (lambda (key) (assoc key entries)) keys)
   (remove (lambda (entry) (member (car entry) keys)) entries)))

(define (vendor-label name)
  "Use the reviewed Chinese vendor name in compact sidebar choices."
  (let ((match (string-match "（([^（）]+)）$" name)))
    (if match (match:substring match 1) name)))

(define (write-face-manifest face destination)
  "Write one public face manifest and attach its content-addressed URL."
  (let* ((content (scm->json-string `(("samples" . ,(jref face "samples")))))
         (name (string-append "assets/previews/" (text-digest content) ".json")))
    (write-text (string-append destination "/" name) content)
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

(define (augment-package package catalog previews revision destination)
  "Join reviewed package facts, previews and a permanent source URL."
  (let* ((faces (jarray (jref (jref previews (jref package "id")) "faces")))
         (name (jref package "displayName"))
         (source (jref package "source"))
         (path (string-join
                (map uri-encode (string-split (jref source "path") #\/))
                "/")))
    (merge package
           `(("preview"
              ("kind" . "image")
              ("faces" . ,(list->vector
                           (map (lambda (face)
                                  (write-face-manifest face destination))
                                faces))))
             ("cover" . ,(write-face-manifest
                          (cover-face name faces) destination))
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

(define (substitute-template template substitutions)
  "Replace literal template markers once without locale-sensitive match offsets."
  (call-with-output-string
   (lambda (port)
     (let loop ((start 0))
       (let ((next
              (fold (lambda (entry found)
                      (let ((position (string-contains template (car entry) start)))
                        (if (and position
                                 (or (not found) (< position (car found))))
                            (cons position entry)
                            found)))
                    #f substitutions)))
         (if next
             (begin
               (display (substring template start (car next)) port)
               (display (cddr next) port)
               (loop (+ (car next) (string-length (cadr next)))))
             (display (substring template start) port)))))))

(define (render-catalog catalog destination revision)
  "Write the complete static catalog and build-pinned navigation for REVISION."
  (unless
      (string-match "^[0-9a-f]{40}$" revision)
    (error "Expected a full Git commit SHA for source permalinks" revision))
  (let* ((previews (read-json (string-append destination "/previews.json")))
         (raw (jarray (jref catalog "packages"))))
    (unless
        (equal?
         (sort (map car previews) string<?)
         (sort (map (lambda (p) (jref p "id")) raw) string<?))
      (error "Expected previews for every font package"))
    (mkdir-p (string-append destination "/assets/previews"))
    (let* ((packages
            (map (lambda (p)
                   (augment-package p catalog previews revision destination))
                 raw))
           (languages
            (prioritize
             '("zh-cn" "en" "zh-tw" "zh-hk" "ja" "ko")
             (map (lambda (key) (cons key (language-label key)))
                  (sort (delete-duplicates
                         (append-map
                          (lambda (p)
                            (catalog-languages (jarray (jref p "languages"))))
                          packages))
                        string<?))))
           (vendors
            (prioritize
             '("tsangertype" "trionestype" "lxgw" "alibaba")
             (map (lambda (entry)
                    (cons (car entry) (vendor-label (cdr entry))))
                  (jref catalog "vendors"))))
           (costs (prioritize
                   '("commercialFree" "personalFree" "paid" "none")
                   (jref catalog "licenseCostLabels")))
           (licenses
            (append
             '(("open" . "开源许可") ("proprietary" . "专有许可"))
             (if (any (lambda (p)
                        (member
                         "unknown"
                         (jarray (jref p "licenseCategories"))))
                      packages)
                 '(("unknown" . "未知"))
                 '())))
           (base (string-append source-repository "/blob/" revision))
           (substitutions
            `(("<!-- facets -->" . ,(string-append
                                     (facet-html "language" "语言" languages '("zh-cn") 6 #t)
                                     (facet-html
                                      "style"
                                      "风格"
                                      (prioritize
                                       '("sans" "serif" "hei" "song" "kai" "fangsong")
                                       (jref catalog "styleLabels"))
                                      '("sans")
                                      6
                                      #t)
                                     (facet-html "vendor" "字库" vendors (map car vendors) 4 #t)
                                     (facet-html "cost" "费用" costs (map car costs) 4 #f)
                                     (facet-html "license" "许可类别" licenses '("open") 3 #f)))
              ("<!-- count -->" . ,(number->string (length packages)))
              ("<!-- language-labels -->"
               . ,(string-replace-substring
                   (scm->json-string languages) "<" "\\u003c"))
              ("<!-- packages -->"
               . ,(string-join
                   (map (lambda (package)
                          (package-html package (jref catalog "noticeLevelLabels")))
                        packages)
                   "\n"))
              ("@README@" . ,(string-append base "/README"))
              ("@WEBSITE_SOURCE@"
               . ,(string-append source-repository "/tree/" revision "/site"))
              ("@LICENSE@" . ,(string-append base "/COPYING"))
              ("@COMMIT@"
               . ,(string-append source-repository "/commit/" revision))
              ("@REVISION@" . ,(substring revision 0 10))))
           (page (substitute-template (read-text (web-file "index.html"))
                                      substitutions)))
      (write-text (string-append destination "/index.html") page)
      (write-json
       (string-append destination "/catalog.json")
       (merge catalog
              `(("schema" . 5)
                ("sourceRepository" . ,source-repository)
                ("sourceRevision" . ,revision)
                ("languageLabels" . ,languages)
                ("packages" . ,(list->vector (map public-package packages))))))
      (format
       #t
       "Rendered ~a font packages with source permalinks at ~a.~%"
       (length packages)
       revision))))
