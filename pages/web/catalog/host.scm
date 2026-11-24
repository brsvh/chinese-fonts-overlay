(define-module (catalog host)
  #:use-module (hoot ffi)
  #:export (nodes listen!
            element-by-id
            create-element
            element-value
            element-text
            element-attribute
            element-query
            checked?
            set-checked!
            set-indeterminate!
            set-value!
            set-text!
            set-hidden!
            set-inert!
            in-viewport?
            set-disabled!
            set-attribute!
            set-style!
            text-fits?
            observe-size!
            clear-children!
            append-child!
            observe!
            json-parse
            json-object
            json-text
            json-has
            current-url
            url-parameter
            set-parameter!
            delete-parameter!
            push-url!
            on-history!
            start-timer
            clear-timer!
            after-paint!
            on-presentation-ready!
            finish-startup!
            timestamp
            fetch-json
            abort-request!
            copy-text!))

(define-foreign element-by-id
  "document" "getElementById"
  (ref string) -> (ref extern))

(define-foreign elements-by-selector
  "document" "querySelectorAll"
  (ref string) -> (ref extern))

(define-foreign create-element
  "document" "createElement"
  (ref string) -> (ref extern))

(define-foreign collection-length
  "collection" "length"
  (ref extern) -> i32)

(define-foreign collection-ref
  "collection" "ref"
  (ref extern) i32 -> (ref extern))

(define-foreign element-value
  "element" "value"
  (ref extern) -> (ref string))

(define-foreign element-text
  "element" "text"
  (ref extern) -> (ref string))

(define-foreign element-attribute
  "element" "attribute"
  (ref extern) (ref string) -> (ref string))

(define-foreign element-query
  "element" "query"
  (ref extern) (ref string) -> (ref extern))

(define-foreign checked?
  "element" "checked"
  (ref extern) -> i32)

(define-foreign set-checked!
  "element" "setChecked"
  (ref extern) i32 -> none)

(define-foreign set-indeterminate!
  "element" "setIndeterminate"
  (ref extern) i32 -> none)

(define-foreign set-value!
  "element" "setValue"
  (ref extern) (ref string) -> none)

(define-foreign set-text!
  "element" "setText"
  (ref extern) (ref string) -> none)

(define-foreign set-hidden!
  "element" "setHidden"
  (ref extern) i32 -> none)

(define-foreign set-inert!
  "element" "setInert"
  (ref extern) i32 -> none)

(define-foreign in-viewport?
  "element" "inViewport"
  (ref extern) i32 -> i32)

(define-foreign set-disabled!
  "element" "setDisabled"
  (ref extern) i32 -> none)

(define-foreign set-attribute!
  "element" "setAttribute"
  (ref extern) (ref string) (ref string) -> none)

(define-foreign set-style!
  "element" "setStyle"
  (ref extern) (ref string) (ref string) -> none)

(define-foreign text-fits?
  "element" "textFits"
  (ref extern) -> i32)

(define-foreign observe-size!
  "element" "observeSize"
  (ref extern) (ref extern) -> none)

(define-foreign on-event!
  "element" "onEvent"
  (ref extern) (ref string) (ref extern) -> none)

(define-foreign clear-children!
  "element" "clear"
  (ref extern) -> none)

(define-foreign append-child!
  "element" "append"
  (ref extern) (ref extern) -> none)

(define-foreign observe!
  "element" "observe"
  (ref extern) (ref extern) -> none)

(define-foreign json-parse
  "json" "parse"
  (ref string) -> (ref extern))

(define-foreign json-object
  "json" "object"
  (ref extern) (ref string) -> (ref extern))

(define-foreign json-text
  "json" "text"
  (ref extern) (ref string) -> (ref string))

(define-foreign json-has
  "json" "has"
  (ref extern) (ref string) -> i32)

(define-foreign current-url
  "browser" "url"
  -> (ref extern))

(define-foreign url-parameter
  "browser" "parameter"
  (ref extern) (ref string) (ref string) -> (ref string))

(define-foreign set-parameter!
  "browser" "setParameter"
  (ref extern) (ref string) (ref string) -> none)

(define-foreign delete-parameter!
  "browser" "deleteParameter"
  (ref extern) (ref string) -> none)

(define-foreign push-url!
  "browser" "pushURL"
  (ref extern) -> none)

(define-foreign on-history!
  "browser" "onHistory"
  (ref extern) -> none)

(define-foreign start-timer
  "browser" "timer"
  i32 (ref extern) -> i32)

(define-foreign clear-timer!
  "browser" "clearTimer"
  i32 -> none)

(define-foreign after-paint!
  "browser" "afterPaint"
  (ref extern) -> none)

(define-foreign on-presentation-ready!
  "browser" "onPresentationReady"
  (ref extern) -> none)

(define-foreign finish-startup!
  "browser" "finishStartup"
  -> none)

(define-foreign timestamp
  "browser" "now"
  -> (ref string))

(define-foreign fetch-json
  "browser" "fetchJSON"
  (ref string) (ref extern) (ref extern) -> (ref extern))

(define-foreign abort-request!
  "browser" "abort"
  (ref extern) -> none)

(define-foreign copy-text!
  "browser" "copyText"
  (ref string) (ref extern) (ref extern) -> none)

(define (nodes selector)
  "Snapshot the nodes matching SELECTOR in document order."
  (let ((collection (elements-by-selector selector)))
    (let loop ((index (- (collection-length collection) 1)) (result '()))
      (if (< index 0)
          result
          (loop (- index 1) (cons (collection-ref collection index) result))))))

(define (listen! element event proc)
  "Keep PROC alive as a callback for the lifetime of this static page."
  (on-event! element event (procedure->external proc)))
