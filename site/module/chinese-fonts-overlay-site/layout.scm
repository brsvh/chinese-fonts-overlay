(define-module (chinese-fonts-overlay-site layout)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (sxml simple)
  #:use-module (ice-9 regex)
  #:export (source-repository site-header site-footer site-markup
                              site-presentation-head site-loader))

(define source-repository "https://github.com/brsvh/chinese-fonts-overlay")

(define (site-presentation-head prefix)
  "Share the early font gate and resources relative to the trusted PREFIX."
  (string-append
   (read-text (web-file "startup-head.html"))
   (site-markup
    `((link (@ (rel "preload") (as "font") (type "font/ttf")
               (crossorigin "anonymous")
               (href ,(string-append prefix "yuyang-regular.ttf"))))
      (link (@ (rel "preload") (as "font") (type "font/ttf")
               (crossorigin "anonymous")
               (href ,(string-append prefix "yuyang-medium.ttf"))))
      ,@(if (file-exists? (web-file "concourse_ot_3_book.woff2"))
            (map (lambda (name)
                   `(link (@ (rel "preload") (as "font") (type "font/woff2")
                             (crossorigin "anonymous")
                             (href ,(string-append prefix name)))))
                 '("concourse_ot_3_book.woff2" "triplicate_a_code_regular.woff2"))
            '())
      (link (@ (rel "stylesheet") (href ,(string-append prefix "fonts.css"))))
      (link (@ (rel "stylesheet") (href ,(string-append prefix "style.css"))))))
   "<script defer src=\"" prefix "presentation.js\"></script>"))

(define (site-loader)
  "Render the initial loading indicator, hidden when JavaScript is disabled."
  (site-markup
   '(div (@ (id "page-loader") (role "status") (aria-live "polite"))
         (span (@ (class "startup-spinner") (aria-hidden "true")) "")
         (span "正在加载..."))))

(define (site-markup tree)
  "Serialize a shared HTML component with escaped text and attributes."
  (call-with-output-string (lambda (port) (sxml->xml tree port))))

(define (site-header prefix current)
  "Render shared navigation relative to PREFIX, selecting CURRENT."
  (define (navigation destination label page)
    (let ((attributes `((href ,destination))))
      `(a (@ ,@attributes
             ,@(if (eq? current page) '((aria-current "page")) '()))
          ,label)))
  (site-markup
   `(header
     (@ (class "header"))
     (a (@ (class "brand") (href ,prefix) (aria-label "Nix中文字体包首页"))
        (img (@ (class "mark") (src ,(string-append prefix "favicon.svg"))
                (width "34") (height "34") (alt "")))
        (span (span (@ (class "brand-title")) "Nix中文字体包")
              (span (@ (class "brand-sub")) "chinese-fonts-overlay")))
     (nav (@ (class "nav") (aria-label "主导航"))
          ,(navigation prefix "字体预览" 'preview)
          ,(navigation (string-append prefix "manual/index.html") "使用手册" 'manual)
          (a (@ (href ,source-repository)) "源码仓库 ↗"))
     (a (@ (class "mobile-page-link")
           (href ,(if (eq? current 'manual) prefix
                      (string-append prefix "manual/index.html"))))
        ,(if (eq? current 'manual) "字体预览" "使用手册"))
     ,(if (eq? current 'manual)
          `(label (@ (class "btn btn-ghost btn-sm mobile-filter")
                     (for "manual-menu-toggle")) "目录")
          `(button (@ (id "sidebar-toggle")
                      (class "btn btn-ghost btn-sm mobile-filter")
                      (type "button") (aria-controls "sidebar")
                      (aria-expanded "false") (data-interactive "")
                      (disabled "disabled")) "筛选")))))

(define (site-footer prefix revision)
  "Render the common footer using PREFIX and the full source REVISION."
  (unless (string-match "^[0-9a-f]{40}$" revision)
    (error "Expected a source revision for the site footer" revision))
  (let ((base (string-append source-repository "/blob/" revision))
        (separator '(span (@ (class "footer-separator") (aria-hidden "true")) "")))
    (site-markup
     `(footer
       (@ (class "site-footer") (aria-label "网站信息"))
       (a (@ (href ,(string-append source-repository "/commit/" revision)))
          "字体数据 " (code ,(substring revision 0 10)))
       ,separator
       (a (@ (href ,(string-append source-repository "/tree/" revision "/site")))
          "网站源代码")
       ,separator
       (span "由 " (a (@ (href "https://spritely.institute/hoot/")) "Hoot") " 驱动")
       ,separator
       (a (@ (class "site-license") (href ,(string-append base "/COPYING")))
          "网站许可 "
          (img (@ (src ,(string-append prefix "cc0.svg"))
                  (width "80") (height "15") (alt "CC0 1.0"))))
       ,separator
       (a (@ (href ,(string-append prefix "licenses.html"))) "第三方声明")))))
