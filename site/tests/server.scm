(use-modules
 (chinese-fonts-overlay-site server)
 (chinese-fonts-overlay-site util)
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

(write-text (string-append temporary "/private") "private")

(symlink (string-append temporary "/private") (string-append root "/outside"))

(let-values
    (((response body) (file-response root (build-request
                                           (string->uri "http://localhost/")))))
  (test-equal "UTF-8 representation" (string->utf8 "中文预览") body)
  (test-equal "Byte content length"
    (bytevector-length body)
    (response-content-length response))
  (test-equal "HTML media type"
    'text/html
    (car (response-content-type response))))

(let-values
    (((response body)
      (file-response root (build-request (string->uri "http://localhost/")
                                         #:method 'HEAD))))
  (test-assert "HEAD is bodyless" (not body))
  (test-equal "HEAD keeps GET length" 12 (response-content-length response)))

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
