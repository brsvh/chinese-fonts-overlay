(define-module (chinese-fonts-overlay pages manual page)
  #:use-module (chinese-fonts-overlay pages manual validation)
  #:use-module (chinese-fonts-overlay pages presentation layout)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:export (install-manual))

(define (entry-file entry)
  "Return the HTML filename referenced by navigation ENTRY."
  (car (string-split (jref entry "href") #\#)))

(define (navigation-entries navigation)
  "Flatten NAVIGATION in reading order, retaining headings at every level."
  (append-map (lambda (entry)
                (cons entry (navigation-entries (jarray (jref entry "children")))))
              navigation))

(define (contains-entry? entry current)
  "Check whether ENTRY or a descendant identifies CURRENT's exact link."
  (or (equal? (jref entry "href") current)
      (any (lambda (child) (contains-entry? child current))
           (jarray (jref entry "children")))))

(define (navigation-link entry current)
  "Render ENTRY, marking the page heading identified by CURRENT."
  `(a (@ (href ,(jref entry "href"))
         ,@(if (equal? (jref entry "href") current)
               '((aria-current "page")) '()))
      ,(jref entry "label")))

(define (navigation-item entry current)
  "Render ENTRY and its nested sections, opening CURRENT's ancestry."
  (let ((children (jarray (jref entry "children"))))
    `(li ,(if (null? children)
              (navigation-link entry current)
              `(details
                (@ ,@(if (contains-entry? entry current)
                         '((open "open")) '()))
                (summary ,(navigation-link entry current))
                (ul ,@(map (lambda (child) (navigation-item child current))
                           children)))))))

(define (manual-sidebar navigation current)
  "Render the nested chapter directory, selecting CURRENT's exact link."
  (site-markup
   `(aside
     (@ (id "manual-sidebar") (class "sidebar manual-sidebar")
        (aria-label "手册目录"))
     (div (@ (class "sidebar-heading")) (h2 "使用手册"))
     (nav (@ (aria-label "章节"))
          (ul (@ (class "manual-chapters"))
              ,@(map (lambda (entry) (navigation-item entry current)) navigation)))
     (a (@ (class "manual-download") (href "chinese-fonts-overlay.info")
           (download "chinese-fonts-overlay.info")) "下载 Info 手册 ↓"))))

(define (manual-pager navigation current)
  "Render links to the distinct pages before and after CURRENT."
  (let ((index (list-index (lambda (entry) (equal? (entry-file entry) current))
                           navigation)))
    (site-markup
     `(nav (@ (class "manual-pager") (aria-label "前后页面")) ""
           ,@(if (and index (> index 0))
                 `((a (@ (rel "prev")
                         (href ,(jref (list-ref navigation (- index 1)) "href")))
                      "← " ,(jref (list-ref navigation (- index 1)) "label"))) '())
           ,@(if (and index (< (+ index 1) (length navigation)))
                 `((a (@ (rel "next")
                         (href ,(jref (list-ref navigation (+ index 1)) "href")))
                      ,(jref (list-ref navigation (+ index 1)) "label") " →")) '())))))

(define (manual-body text)
  "Extract compiler-produced HTML between explicit Texinfo customization markers."
  (let* ((start-marker "<!-- manual-start -->")
         (start (string-contains text start-marker))
         (end (string-contains text "<!-- manual-end -->")))
    (unless (and start end (< start end))
      (error "Missing manual conversion boundaries"))
    (substring text (+ start (string-length start-marker)) end)))

(define (install-manual source output revision)
  "Wrap compiled SOURCE with shared site components in OUTPUT/manual."
  (validate-manual source)
  (let* ((navigation (jarray (read-json (string-append source "/navigation.json"))))
         (entries (navigation-entries navigation))
         (pages (delete-duplicates entries
                                   (lambda (a b)
                                     (equal? (entry-file a) (entry-file b)))))
         (reference (read-json (string-append source "/reference.json")))
         (destination (string-append output "/manual")))
    (unless (equal? revision (jref reference "sourceRevision"))
      (error "Manual and website source revisions differ"))
    (unless (and (pair? navigation)
                 (equal? "index.html" (entry-file (car navigation))))
      (error "Manual navigation requires an index page"))
    (mkdir-p destination)
    (for-each
     (lambda (file)
       (let* ((name (basename file))
              (entry (find (lambda (entry) (equal? name (entry-file entry)))
                           pages))
              (title (if entry (jref entry "label") "使用手册")))
         (write-text
          (string-append destination "/" name)
          (string-append
           "<!doctype html>\n<html lang=\"zh-CN\"><head>"
           (site-markup
            `((meta (@ (charset "utf-8")))
              (meta (@ (name "viewport")
                       (content "width=device-width, initial-scale=1")))
              (title ,title " · Chinese Fonts Overlay")
              (link (@ (rel "icon") (type "image/svg+xml") (href "../favicon.svg")))))
           (site-presentation-head "../")
           "<script defer src=\"../manual.js\"></script>"
           "</head><body class=\"manual-page\">"
           (site-loader)
           "<p id=\"manual-status\" class=\"sr-only\" role=\"status\"></p>"
           "<a class=\"skip-link\" href=\"#manual-main\">跳转到正文</a>"
           (site-header "../" 'manual)
           "<input type=\"checkbox\" id=\"manual-menu-toggle\" class=\"manual-menu-toggle\" aria-label=\"显示手册目录\" aria-controls=\"manual-sidebar\">"
           "<div class=\"shell\">"
           (manual-sidebar navigation (and entry (jref entry "href")))
           "<main id=\"manual-main\" class=\"main manual-main\" tabindex=\"-1\">"
           "<article class=\"manual-content\">"
           (manual-body (read-text file)) "</article>"
           (manual-pager pages name) (site-footer "../" revision)
           "</main></div></body></html>\n"))))
     (filter (lambda (file) (string-suffix? ".html" file))
             (files-under (string-append source "/html"))))
    (copy-file (string-append source "/chinese-fonts-overlay.info")
               (string-append destination "/chinese-fonts-overlay.info"))))
