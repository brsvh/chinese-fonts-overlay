(use-modules
 (server http)
 (util)
 (ice-9 binary-ports)
 (ice-9 match)
 (rnrs bytevectors)
 (srfi srfi-11)
 (srfi srfi-64)
 (web request)
 (web response)
 (web uri))

(test-begin "server")

(define runner (test-runner-current))

(define temporary (temporary-directory (or (getenv "TMPDIR") "/tmp")))

(define root (string-append temporary "/public"))

(mkdir-p root)

(write-text (string-append root "/index.html") "中文预览")

(write-text (string-append root "/a+b.json") "{}")
(write-text (string-append root "/interface.woff2") "wOF2")

(define image-bytes #vu8(0 128 255 13 10))

(call-with-output-file
    (string-append root "/sample.webp")
  (lambda (port) (put-bytevector port image-bytes))
  #:binary #t)

(write-text (string-append temporary "/private") "private")

(symlink (string-append temporary "/private") (string-append root "/outside"))

(for-each
 (match-lambda
   ((path media-type expected)
    (for-each
     (lambda (method)
       (let-values
           (((response body)
             (file-response
              root
              (build-request
               (string->uri (string-append "http://localhost" path))
               #:method method))))
         (test-assert (format #f "~a ~a preserves its HTTP representation"
                             method path)
           (and (= 200 (response-code response))
                (eq? media-type (car (response-content-type response)))
                (= (bytevector-length expected)
                   (response-content-length response))
                (if (eq? method 'HEAD)
                    (not body)
                    (equal? body expected))))))
     '(GET HEAD))))
 `(("/" text/html ,(string->utf8 "中文预览"))
   ("/interface.woff2" font/woff2 ,(string->utf8 "wOF2"))
   ("/sample.webp" image/webp ,image-bytes)))

(for-each
 (lambda (entry)
   (let-values
       (((response body)
         (file-response
          root
          (build-request
           (string->uri (string-append "http://localhost" (car entry)))))))
     (test-equal (car entry) (cdr entry) (response-code response))))
 '(("/missing" . 404)
   ("/outside" . 404)
   ("/%2e%2e/private" . 404)
   ("/a+b.json" . 200)
   ("/a%2Bb.json" . 200)
   ("/a%252Bb.json" . 404)
   ("/%00" . 400)
   ("/%xx" . 400)))

(let-values
    (((response body)
      (file-response root (build-request (string->uri "http://localhost/")
                                         #:method 'OPTIONS))))
  (test-equal "Only GET and HEAD" 405 (response-code response)))

(delete-tree temporary)

(test-end "server")

(exit (zero? (test-runner-fail-count runner)))
