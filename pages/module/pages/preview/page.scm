(define-module (chinese-fonts-overlay pages preview page)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (chinese-fonts-overlay pages preview samples)
  #:use-module (chinese-fonts-overlay pages presentation layout)
  #:use-module (ice-9 format)
  #:use-module (ice-9 string-fun)
  #:use-module (json)
  #:use-module (srfi srfi-1)
  #:export (write-preview-page!))

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
    (site-markup
     `(article
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
                                              '("free" "gratisCommercialUse"))
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
  (define (find-group start)
    "Find the next unnested bracket pair using Unicode character positions."
    (and (< start (string-length text))
         (let* ((opening (string-ref text start))
                (pair (assv opening
                            '((#\（ . #\）) (#\( . #\)) (#\「 . #\」)
                              (#\『 . #\』) (#\【 . #\】) (#\《 . #\》))))
                (end (and pair
                          (string-index
                           text
                           (lambda (character)
                             (or (char=? character opening)
                                 (char=? character (cdr pair))))
                           (+ start 1)))))
           (if (and end (char=? (string-ref text end) (cdr pair)))
               (cons start (+ end 1))
               (find-group (+ start 1))))))
  (let ((group (find-group 0)))
    (if group
        (append
         (if (zero? (car group))
             '()
             `((span (@ (class "facet-phrase")) ,(substring text 0 (car group)))))
         `((span (@ (class "facet-phrase"))
                 ,(substring text (car group) (cdr group))))
         (facet-label-content (substring text (cdr group))))
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
  (site-markup
   `(fieldset
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
                      ,@(if (and (pair? labels)
                                 (every (lambda (entry)
                                          (member (car entry) defaults))
                                        labels))
                            '((checked "checked"))
                            '())))
            "全选")
     (div (@ (class ,(if chips? "facet-options" "check-options")))
          ,@(if (null? labels)
                '("")
                (append
                 (map choice (take labels (min limit (length labels))))
                 (if (> (length labels) limit)
                     `((div (@ (class "facet-extra")
                               (id ,(string-append key "-extra"))
                               (hidden "hidden"))
                            ,@(map choice (drop labels limit))))
                     '()))))
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

(define (vendor-label name)
  "Use the reviewed Chinese vendor name in compact sidebar choices."
  (let ((start (string-rindex name #\（))
        (end (- (string-length name) 1)))
    (if (and start (< (+ start 1) end)
             (char=? (string-ref name end) #\）)
             (not (string-index name #\） (+ start 1) end)))
        (substring name (+ start 1) end)
        name)))

(define (write-preview-page! catalog destination)
  "Write the interactive preview page with readable static package cards."
  (let* ((packages (jarray (jref catalog "packages")))
         (languages (jref catalog "languageLabels"))
         (revision (jref catalog "sourceRevision"))
         (vendors
          (prioritize-entries
           '("tsangertype" "trionestype" "lxgw" "alibaba")
           (map (lambda (entry)
                  (cons (car entry) (vendor-label (cdr entry))))
                (jref catalog "vendors"))))
         (costs (prioritize-entries
                 '("gratisCommercialUse" "gratisPersonalUse" "paid" "free")
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
         (substitutions
          `(("<!-- site-presentation -->" . ,(site-presentation-head "./"))
            ("<!-- site-loader -->" . ,(site-loader))
            ("<!-- site-header -->" . ,(site-header "./" 'preview))
            ("<!-- site-footer -->" . ,(site-footer "./" revision))
            ("<!-- facets -->" . ,(string-append
                                   (facet-html "language" "语言" languages '("zh-cn") 6 #t)
                                   (facet-html
                                    "style"
                                    "风格"
                                    (prioritize-entries
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
             . ,(string-append
                 "<script id=\"language-labels\" type=\"application/json\">"
                 (string-replace-substring (scm->json-string languages)
                                           "<" "\\u003c")
                 "</script>"))
            ("<!-- packages -->"
             . ,(string-join
                 (map (lambda (package)
                        (package-html package (jref catalog "noticeLevelLabels")))
                      packages)
                 "\n"))))
         (page (substitute-template (read-text (web-file "index.html"))
                                    substitutions)))
    (write-text (string-append destination "/index.html") page)))
