(define-module (chinese-fonts-overlay-site github)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (ice-9 regex)
  #:use-module (json)
  #:use-module (srfi srfi-1)
  #:export (github-request github-pages download-asset upload-asset
                           repository github-root require-value matches? positive-id?))

(define repository "brsvh/chinese-fonts-overlay")
(define github-root (string-append "https://api.github.com/repos/" repository))

(define (require-value condition message . arguments)
  "Reject a failed boundary check without printing credentials."
  (unless condition (apply error message arguments)))

(define (matches? pattern value)
  "Match PATTERN only against string VALUE."
  (and (string? value) (regexp-exec (make-regexp pattern) value)))

(define (positive-id? value)
  "Recognize positive JSON integer identifiers."
  (and (exact-integer? value) (> value 0)))

(define* (transfer url destination limit #:key token (method "GET") file
                   (content-type "application/json") (redirects? #f))
  "Transfer bounded HTTPS data; keep TOKEN in an owned private file."
  (let ((temporary (temporary-directory (or (getenv "TMPDIR") "/tmp"))))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (let ((header (string-append temporary "/authorization")))
            (when token
              ;; Tokens are opaque; validate only the single-line HTTP boundary.
              (require-value (and (string? token) (not (string-null? token))
                                  (string-every
                                   (lambda (character)
                                     (<= 33 (char->integer character) 126))
                                   token))
                             "Invalid credential format")
              (write-text header (string-append "Authorization: Bearer " token "\n"))
              (chmod header #o600))
            (apply run
                   (append
                    (list "curl" "--disable" "--silent" "--show-error" "--fail"
                          "--proto" "=https" "--proto-redir" "=https"
                          "--connect-timeout" "30" "--max-time" "900"
                          "--max-filesize" (number->string limit)
                          "--output" destination "--request" method
                          "--header" "Accept: application/vnd.github+json"
                          "--header" "X-GitHub-Api-Version: 2022-11-28")
                    (if token (list "--header" (string-append "@" header)) '())
                    (if redirects? '("--location" "--max-redirs" "5") '())
                    (if file
                        (list "--header" (string-append "Content-Type: " content-type)
                              "--data-binary" (string-append "@" file))
                        '())
                    (list url)))
            (require-value (<= (stat:size (stat destination)) limit)
                           "Response exceeds size limit")))
        (lambda () (delete-tree temporary)))))

(define* (github-request token path #:key (method "GET") data)
  "Call the fixed repository API, optionally sending JSON DATA."
  (require-value (and (string-prefix? "/" path)
                      (not (string-prefix? "//" path))
                      (not (string-any char-whitespace? path)))
                 "Invalid repository API path")
  (let ((temporary (temporary-directory (or (getenv "TMPDIR") "/tmp"))))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (let ((input (string-append temporary "/request.json"))
                (output (string-append temporary "/response.json")))
            (when data (write-json input data))
            (transfer (string-append github-root path) output (* 16 1024 1024)
                      #:token token #:method method #:file (and data input))
            (if (zero? (stat:size (stat output))) #f (read-json output))))
        (lambda () (delete-tree temporary)))))

(define* (github-pages token path #:optional field)
  "Read a bounded paginated API collection, or FIELD within each response."
  (let loop ((page 1) (result '()))
    (require-value (<= page 100) "API pagination limit exceeded")
    (let* ((response (github-request
                      token (string-append path
                                           (if (string-contains path "?") "&" "?")
                                           "per_page=100&page="
                                           (number->string page))))
           (items (if field (jref response field) response)))
      (require-value (vector? items) "Invalid API collection")
      (let ((combined (append result (vector->list items))))
        (if (< (vector-length items) 100) combined
            (loop (+ page 1) combined))))))

(define (download-asset asset destination)
  "Download a public release asset without forwarding any credentials."
  (let ((name (jref asset "name")) (size (jref asset "size")))
    (require-value (and (matches? "^[A-Za-z0-9.-]+$" name)
                        (positive-id? size) (< size 1000000000))
                   "Invalid asset download")
    (transfer (string-append "https://github.com/" repository
                             "/releases/download/site-artifacts/" name)
              destination size #:redirects? #t)
    (require-value (and (= size (stat:size (stat destination)))
                        (equal? (jref asset "digest")
                                (string-append "sha256:" (file-digest destination))))
                   "Downloaded asset digest or size mismatch")))

(define (upload-asset token release-id file content-type)
  "Upload a new named file; callers must never replace an existing asset."
  (require-value (and (positive-id? release-id)
                      (matches? "^[A-Za-z0-9.-]+$" (basename file)))
                 "Invalid release upload")
  (let ((temporary (temporary-directory (or (getenv "TMPDIR") "/tmp"))))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (let ((output (string-append temporary "/response.json")))
            (transfer
             (string-append "https://uploads.github.com/repos/" repository
                            "/releases/" (number->string release-id)
                            "/assets?name=" (basename file))
             output (* 1024 1024) #:token token #:method "POST" #:file file
             #:content-type content-type)
            (read-json output)))
        (lambda () (delete-tree temporary)))))
