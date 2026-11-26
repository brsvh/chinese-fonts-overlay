(define-module (chinese-fonts-overlay pages server http)
  #:use-module (ice-9 binary-ports)
  #:use-module (web server)
  #:use-module (web request)
  #:use-module (web response)
  #:use-module (web uri)
  #:export (serve-site file-response))

(define (content-type path)
  "Return the parsed HTTP media type for a public asset PATH."
  (cond
   ((string-suffix? ".html" path) '(text/html (charset . "utf-8")))
   ((string-suffix? ".js" path) '(text/javascript (charset . "utf-8")))
   ((string-suffix? ".json" path) '(application/json (charset . "utf-8")))
   ((string-suffix? ".css" path) '(text/css (charset . "utf-8")))
   ((string-suffix? ".ttf" path) '(font/ttf))
   ((string-suffix? ".woff2" path) '(font/woff2))
   ((string-suffix? ".pdf" path) '(application/pdf))
   ((string-suffix? ".wasm" path) '(application/wasm))
   ((string-suffix? ".webp" path) '(image/webp))
   ((string-suffix? ".svg" path) '(image/svg+xml))
   (else '(application/octet-stream))))

(define (decode-segment raw)
  "Decode one URI path segment RAW once; reject malformed escapes, NUL, or '/'."
  (and (let loop ((index 0))
         (or (= index (string-length raw))
             (if (char=? (string-ref raw index) #\%)
                 (and (< (+ index 2) (string-length raw))
                      (char-set-contains?
                       char-set:hex-digit
                       (string-ref raw (+ index 1)))
                      (char-set-contains?
                       char-set:hex-digit
                       (string-ref raw (+ index 2)))
                      (loop (+ index 3)))
                 (loop (+ index 1)))))
       (catch 'decoding-error
         (lambda ()
           (let ((name (uri-decode raw #:decode-plus-to-space? #f)))
             (and (not (string-index name #\nul))
                  (not (string-index name #\/))
                  name)))
         (lambda _ #f))))

(define (decode-path raw)
  "Decode RAW per path segment, preserving plus signs; return false if malformed."
  (and (string-prefix? "/" raw)
       (let loop ((segments (string-split raw #\/)) (decoded '()))
         (if (null? segments)
             (string-join (reverse decoded) "/")
             (let ((part (decode-segment (car segments))))
               (and part (loop (cdr segments) (cons part decoded))))))))

(define (file-response root request)
  "Serve GET or HEAD beneath ROOT, enforcing canonical path containment."
  (define (failure code message)
    (values
     (build-response
      #:code
      code
      #:headers
      '((content-type text/plain (charset . "utf-8"))))
     message))
  (if (not (memq (request-method request) '(GET HEAD)))
      (values
       (build-response #:code 405 #:headers '((allow GET HEAD)))
       "Method not allowed\n")
      (let ((name (decode-path (uri-path (request-uri request)))))
        (if (not name)
            (failure 400 "Malformed path\n")
            (catch 'system-error
              (lambda ()
                (let* ((base (canonicalize-path root))
                       (path (canonicalize-path
                              (string-append
                               base
                               name
                               (if (string-suffix? "/" name) "index.html" "")))))
                  (if (and (string-prefix? (string-append base "/") path)
                           (eq? 'regular (stat:type (stat path))))
                      (values
                       (build-response
                        #:headers
                        `((content-type . ,(content-type path))
                          (content-length . ,(stat:size (stat path)))
                          (cache-control no-cache)))
                       (if (eq? (request-method request) 'HEAD)
                           #f
                           (let ((bytes (call-with-input-file
                                            path
                                          get-bytevector-all
                                          #:binary
                                          #t)))
                             (if (eof-object? bytes) #vu8() bytes))))
                      (failure 404 "Not found\n"))))
              (lambda args
                (if (memv (system-error-errno args) (list ENOENT ENOTDIR))
                    (failure 404 "Not found\n")
                    (begin
                      (print-exception
                       (current-error-port)
                       #f
                       (car args)
                       (cdr args))
                      (failure 500 "Internal server error\n")))))))))

(define (serve-site output port)
  "Serve OUTPUT on loopback PORT until interrupted."
  (let ((root (canonicalize-path output)))
    (format #t "Serving ~a at http://127.0.0.1:~a/~%" root port)
    (force-output)
    (run-server
     (lambda (request body) (file-response root request))
     'http
     `(#:addr ,INADDR_LOOPBACK #:port ,port))))
