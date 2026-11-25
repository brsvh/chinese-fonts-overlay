(define-module (chinese-fonts-overlay pages manual reference)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (web uri)
  #:export (generate-reference))

(define (texinfo value)
  "Escape literal VALUE, including delimiters in command arguments."
  (string-concatenate
   (map (lambda (character)
          (case character
            ((#\@) "@@") ((#\{) "@{") ((#\}) "@}")
            ((#\,) "@comma{}")
            ((#\:) "@asis{:}")
            (else (string character))))
        (string->list value))))

(define (link url label)
  "Return a Texinfo link to URL with literal LABEL."
  (if (or (string-prefix? "https://" url) (string-prefix? "http://" url)
          (string-prefix? "../?" url))
      (format #f "@url{~a, ~a}" (texinfo url) (texinfo label))
      (texinfo label)))

(define (package-node package)
  "Give PACKAGE a stable Info node independent of its display name."
  (string-append
   "Package-"
   (string-concatenate
    (map (lambda (character)
           (if (or (char-alphabetic? character) (char-numeric? character)
                   (char=? character #\-))
               (string character)
               (string-append "_" (number->string (char->integer character) 16) "_")))
         (string->list (jref package "id"))))))

(define (vendor-node vendor)
  "Give VENDOR a stable section node."
  (string-append "Vendor-" vendor))

(define (field label value)
  "Write an ordinary table field LABEL containing prepared Texinfo VALUE."
  (format #t "@item ~a\n~a\n\n" label value))

(define (package-section package catalog languages revision)
  "Write one PACKAGE reference using evaluated CATALOG facts."
  (let ((attribute (jref package "attribute")))
    (format #t "@node ~a\n@subsection ~a\n@paindex ~a\n\n"
            (package-node package) (texinfo (jref package "displayName"))
            (texinfo attribute))
    (format #t "@table @asis\n")
    (field "安装属性" (format #f "@code{~a}" (texinfo attribute)))
    (field "简介" (texinfo (jref package "description")))
    (unless (string-null? (string-trim-both (jref package "longDescription")))
      (field "详细介绍" (texinfo (string-trim-both
                                  (jref package "longDescription")))))
    (field "版本" (texinfo (jref package "version")))
    (field "风格"
           (string-join (map (lambda (key)
                               (texinfo (jref (jref catalog "styleLabels") key)))
                             (jarray (jref package "styles"))) "、"))
    (field "支持语言"
           (if (null? (jarray (jref package "languages"))) "未检测到语言覆盖。"
               (string-append
                "@itemize @asis{}\n"
                (string-concatenate
                 (map (lambda (code)
                        (format #f "@item ~a（@code{~a}）\n"
                                (texinfo (jref languages code code)) (texinfo code)))
                      (jarray (jref package "languages"))))
                "@end itemize")))
    (field "许可费用" (texinfo (jref (jref catalog "licenseCostLabels")
                                     (jref package "licenseCost"))))
    (field "许可"
           (string-join
            (map (lambda (license)
                   (if (string? (jref license "url"))
                       (link (jref license "url") (jref license "name"))
                       (texinfo (jref license "name"))))
                 (jarray (jref package "licenses"))) "；"))
    (field "再分发" (if (jref package "redistributable") "允许" "不允许"))
    (field "嵌入式使用"
           (if (jref package "embedding") "允许，须遵循许可中的条件。"
               "本包未提供此项许可；另行授权的条件请咨询发行方。"))
    (field "上游主页"
           (string-join (map (lambda (url) (link url url))
                             (jarray (jref package "homepages"))) "\n\n"))
    (field "包定义"
           (link (string-append
                  "https://github.com/brsvh/chinese-fonts-overlay/blob/" revision
                  "/" (jref (jref package "source") "path")) attribute))
    (display "@end table\n\n")
    (write-notices (jref package "notices") catalog)
    (let ((query (string-append "?language=*&style=*&license=*&query="
                                (uri-encode attribute) "#" (jref package "id"))))
      (format #t "@ifhtml\n~a\n@end ifhtml\n@ifnothtml\n~a\n@end ifnothtml\n\n"
              (link (string-append "../" query) "查看字体预览")
              (link (string-append
                     "https://brsvh.org/chinese-fonts-overlay/" query)
                    "查看字体预览")))))

(define (write-notices notices catalog)
  "Write reviewed NOTICES and their source links using CATALOG labels."
  (for-each
   (lambda (notice)
     (format #t "@html\n<aside class=\"manual-notice manual-notice-~a\">\n@end html\n"
             (jref notice "level"))
     (format #t "@quotation ~a\n~a\n\n"
             (texinfo (jref (jref catalog "noticeLevelLabels")
                            (jref notice "level")))
             (texinfo (string-trim-both (jref notice "text"))))
     (when (string? (jref notice "url"))
       (format #t "~a\n\n" (link (jref notice "url") "查看原文")))
     (display "@end quotation\n@html\n</aside>\n@end html\n\n"))
   (jarray notices)))

(define (aggregate-section aggregate packages catalog)
  "Write an AGGREGATE entry and link its actual members in PACKAGES."
  (let ((attribute (texinfo (jref aggregate "attribute")))
        (members (jarray (jref aggregate "members"))))
    (format #t "@paindex ~a\n@strong{@code{~a}}\n\n" attribute attribute)
    (unless (string-null? (jref aggregate "description" ""))
      (format #t "~a\n\n" (texinfo (jref aggregate "description"))))
    (unless (jref aggregate "composed")
      (display "这是直接从上游来源提取的字体集合。\n")
      (display "集合内容以包定义为准，以下单包可分别安装。\n\n"))
    (for-each (lambda (url) (format #t "~a\n\n" (link url url)))
              (jarray (jref aggregate "upstreamUrls" #())))
    (write-notices (jref aggregate "notices" #()) catalog)
    (unless (null? members)
      (display "@itemize @bullet\n")
      (for-each
       (lambda (attribute)
         (let ((package (find (lambda (p) (equal? attribute (jref p "attribute")))
                              packages)))
           (unless package (error "Unknown aggregate member" attribute))
           (format #t "@item\n@ref{~a, , ~a}（@code{~a}）\n"
                   (package-node package) (texinfo (jref package "displayName"))
                   (texinfo attribute)))) members)
      (display "@end itemize\n\n"))))

(define (vendor-section vendor packages catalog languages revision)
  "Write VENDOR's section from PACKAGES with shared metadata labels."
  (let* ((key (car vendor))
         (members (filter (lambda (p) (equal? key (jref p "vendor"))) packages))
         (aggregates
          (filter (lambda (a) (member key (jarray (jref a "vendors"))))
                  (jarray (jref catalog "aggregates" #())))))
    (format #t "@node ~a\n@section ~a\n\n"
            (vendor-node key) (texinfo (cdr vendor)))
    (format #t "本节收录 ~a 个字体包。各包的版本、覆盖语言和许可信息\n"
            (length members))
    (display "来自包定义；许可原文和适用范围请见各条目的链接与说明。\n\n")
    (display "@menu\n")
    (for-each
     (lambda (package)
       (let* ((name (jref package "displayName"))
              ;; Info uses colons to separate a menu label from its target.
              (label (if (string-index name #\:)
                         (jref package "attribute") name)))
         (format #t "* ~a: ~a.~a\n" (texinfo label) (package-node package)
                 (if (equal? label name) ""
                     (string-append " " (texinfo name))))))
     members)
    (display "@end menu\n\n")
    (unless (null? aggregates)
      (display "@subheading 字库合集\n\n")
      (for-each (lambda (aggregate)
                  (aggregate-section aggregate packages catalog)) aggregates))
    (for-each (lambda (package)
                (package-section package catalog languages revision)) members)))

(define (generate-reference catalog languages directory revision)
  "Generate complete reference includes in DIRECTORY from evaluated CATALOG."
  (let* ((packages (jarray (jref catalog "packages")))
         (attributes (map (lambda (p) (jref p "attribute")) packages))
         (vendors (filter (lambda (entry)
                            (any (lambda (p) (equal? (car entry)
                                                     (jref p "vendor")))
                                 packages))
                          (jref catalog "vendors"))))
    (unless (and (pair? packages)
                 (= (length attributes) (length (delete-duplicates attributes))))
      (error "Manual requires a nonempty, unique package catalog"))
    (write-text (string-append directory "/revision.texi")
                (format #f "@set source-revision ~a\n" revision))
    (write-text
     (string-append directory "/fonts-menu.texi")
     (string-concatenate
      (map (lambda (vendor)
             (format #f "* ~a: ~a. 字体包与合集。\n"
                     (texinfo (cdr vendor)) (vendor-node (car vendor)))) vendors)))
    (write-text
     (string-append directory "/vocabulary.texi")
     (call-with-output-string
      (lambda (port)
        (with-output-to-port port
          (lambda ()
            (for-each
             (lambda (entry)
               (format #t "@subheading ~a\n@table @code\n" (cdr entry))
               (for-each (lambda (item) (field (car item) (texinfo (cdr item))))
                         (jref catalog (car entry)))
               (display "@end table\n\n"))
             '(("styleLabels" . "风格标识")
               ("licenseCostLabels" . "费用标识"))))))))
    (write-text
     (string-append directory "/fonts-sections.texi")
     (call-with-output-string
      (lambda (port)
        (with-output-to-port port
          (lambda ()
            (for-each (lambda (vendor)
                        (vendor-section vendor packages catalog languages revision))
                      vendors))))))
    (write-json (string-append directory "/reference.json")
                `(("sourceRevision" . ,revision)
                  ("packages" . ,(list->vector
                                  (map (lambda (p)
                                         `(("node" . ,(package-node p))
                                           ("attribute" . ,(jref p "attribute"))))
                                       packages)))))))
