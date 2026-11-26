(define-module (chinese-fonts-overlay pages manual validation)
  #:use-module (chinese-fonts-overlay pages manual navigation)
  #:use-module (chinese-fonts-overlay pages util)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (web uri)
  #:export (validate-manual))

(define (text-matches pattern text)
  "Match PATTERN within individual TEXT lines to bound Unicode regex work."
  (let ((regexp (make-regexp pattern)))
    (append-map (lambda (line) (list-matches regexp line))
                (string-split text #\newline))))

(define (safe-external-href? href)
  "Accept only explicit HTTP(S) or mailto external links in manual HTML."
  (any (lambda (prefix) (string-prefix? prefix href))
       '("https://" "http://" "mailto:")))

(define (decode-anchor fragment)
  "Decode an HTML anchor FRAGMENT without turning plus signs into spaces."
  (catch 'decoding-error
    (lambda () (uri-decode fragment #:decode-plus-to-space? #f))
    (lambda _ #f)))

(define (validate-manual directory)
  "Check package coverage, local HTML links and Info output in DIRECTORY."
  (let* ((links (internal-links (string-append directory "/links.tsv")))
         (reference (read-json (string-append directory "/reference.json")))
         (packages (jarray (jref reference "packages")))
         (nodes (filter (lambda (entry) (equal? (cadr entry) "node")) links))
         (html (canonicalize-path (string-append directory "/html")))
         (html-prefix (string-append html "/"))
         (pages (filter (lambda (file) (string-suffix? ".html" file))
                        (files-under html)))
         (page-text (map (lambda (file) (cons file (read-text file))) pages))
         (anchors (make-hash-table))
         (info-file (string-append directory "/chinese-fonts-overlay.info"))
         (info (read-text info-file))
         (info-nodes
          (map (lambda (match) (match:substring match 1))
               (filter-map
                (lambda (line)
                  (and (string-prefix? "File:" line)
                       (string-match "Node: ([^,]+)," line)))
                (string-split info #\newline)))))
    (when (or (string-contains info "/nix/store/")
              (string-contains info "file:///"))
      (error "Private path in manual output" info-file))
    (for-each
     (lambda (page)
       (let ((ids (make-hash-table)))
         (for-each (lambda (match) (hash-set! ids (match:substring match 1) #t))
                   (text-matches "id=\"([^\"]+)\"" (cdr page)))
         (hash-set! anchors (car page) ids))) page-text)
    (for-each
     (lambda (package)
       (let ((node (jref package "node")))
         (unless (= 1 (count (lambda (entry) (equal? (caddr entry) node))
                             nodes))
           (error "Package must have exactly one HTML node" node))
         (unless (member node info-nodes)
           (error "Package missing from Info" node)))) packages)
    (for-each
     (lambda (file)
       (let ((text (assoc-ref page-text file)))
         (unless (and (string-contains text "<!-- manual-start -->")
                      (string-contains text "<!-- manual-end -->"))
           (error "Missing HTML conversion boundary" file))
         (when (or (string-contains text "/nix/store/")
                   (string-contains text "file:///"))
           (error "Private path in manual output" file))
         (for-each
          (lambda (match)
            (let ((href (match:substring match 1)))
              (cond
               ((string-prefix? "../?" href) #t)
               ((string-contains href ":")
                (unless (safe-external-href? href)
                  (error "Unsafe manual link scheme" file href)))
               (else
                (let* ((parts (string-split href #\#))
                       (raw-target (if (string-null? (car parts)) file
                                       (string-append html "/" (car parts))))
                       (target (and (file-exists? raw-target)
                                    (canonicalize-path raw-target))))
                  (unless (and target (string-prefix? html-prefix target))
                    (error "Broken manual link" file href))
                  (when (pair? (cdr parts))
                    (let ((anchor (decode-anchor (cadr parts))))
                      (unless (and anchor
                                   (hash-ref
                                    (or (hash-ref anchors target)
                                        (error "Non-HTML manual link" target))
                                    anchor))
                        (error "Broken manual anchor" file href)))))))))
          (text-matches "href=\"([^\"]+)\"" text)))) pages)
    (format #t "Checked ~a packages, ~a HTML pages and Info nodes.~%"
            (length packages) (length pages))))
