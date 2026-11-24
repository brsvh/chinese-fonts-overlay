(define-module (chinese-fonts-overlay pages presentation assets)
  #:use-module (chinese-fonts-overlay pages util)
  #:export (browser-assets))

;; The Makefile reads the same list when preparing the browser bundle.
(define browser-assets
  (string-tokenize (read-text (search-path %load-path "../etc/browser-assets"))))
