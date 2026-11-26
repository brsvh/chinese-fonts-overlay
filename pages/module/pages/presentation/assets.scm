(define-module (chinese-fonts-overlay pages presentation assets)
  #:use-module (chinese-fonts-overlay pages util)
  #:export (browser-assets))

;; The Makefile reads the same list when preparing the browser bundle.
(define cached-browser-assets
  (delay
    (string-tokenize
     (read-text (search-path %load-path "../etc/browser-assets")))))

(define (browser-assets)
  "Return the required browser asset filenames from etc/browser-assets."
  (force cached-browser-assets))
