(use-modules (hoot ffi) (srfi srfi-9) (srfi srfi-13))

(define-foreign element-by-id
  "document" "getElementById"
  (ref string) -> (ref extern))

(define-foreign element-value
  "element" "value"
  (ref extern) -> (ref string))

(define-foreign set-text!
  "element" "setText"
  (ref extern) (ref string) -> none)

(define-foreign on-event!
  "element" "onEvent"
  (ref extern) (ref string) (ref extern) -> none)

(define-foreign elements-by-selector
  "document" "querySelectorAll"
  (ref string) -> (ref extern))

(define-foreign collection-length "collection" "length" (ref extern) -> i32)

(define-foreign collection-ref
  "collection" "ref"
  (ref extern) i32 -> (ref extern))

(define-foreign element-attribute
  "element" "attribute"
  (ref extern) (ref string) -> (ref string))

(define-foreign set-value!
  "element" "setValue"
  (ref extern) (ref string) -> none)

(define-foreign set-hidden! "element" "setHidden" (ref extern) i32 -> none)

(define query (element-by-id "query"))
(define vendor (element-by-id "vendor"))
(define license-cost (element-by-id "license-cost"))
(define license (element-by-id "license"))
(define redistribution (element-by-id "redistribution"))
(define language (element-by-id "language"))
(define style (element-by-id "style"))
(define result-count (element-by-id "result-count"))
(define empty-results (element-by-id "empty-results"))
(define packages (elements-by-selector "#packages > li"))
(define package-count (collection-length packages))

(define (matches-choice? selected actual)
  "Match a single category, treating the empty selection as unrestricted."
  (or (string-null? selected) (string=? selected actual)))

(define (contains-text? text query)
  "Match QUERY at Scheme character boundaries within TEXT.
The selected Hoot runtime does not implement string-contains."
  (let ((limit (- (string-length text) (string-length query))))
    (let loop ((start 0))
      (and (<= start limit)
           (or (string=?
                query
                (substring text start (+ start (string-length query))))
               (loop (+ start 1)))))))

(define (matches-token? selected actual)
  "Match SELECTED as a complete space-separated category token."
  (or (string-null? selected)
      (contains-text?
       (string-append " " actual " ")
       (string-append " " selected " "))))

(define (filter-packages!)
  "Apply all active filters and update package visibility and result counts."
  (let ((text (string-downcase (string-trim-both (element-value query))))
        (chosen-vendor (element-value vendor))
        (chosen-license-cost (element-value license-cost))
        (chosen-license (element-value license))
        (chosen-redistribution (element-value redistribution))
        (chosen-language (element-value language))
        (chosen-style (element-value style)))
    (let loop ((index 0) (visible 0))
      (if (= index package-count)
          (begin
            (set-text!
             result-count
             (string-append
              "显示 "
              (number->string visible)
              " / "
              (number->string package-count)
              " 个字体包"))
            (set-hidden! empty-results (if (= visible 0) 0 1)))
          (let* ((package (collection-ref packages index))
                 (matches
                  (and (contains-text?
                        (string-downcase
                         (element-attribute package "data-search"))
                        text)
                       (matches-choice?
                        chosen-vendor
                        (element-attribute package "data-vendor"))
                       (matches-choice?
                        chosen-license-cost
                        (element-attribute package "data-license-cost"))
                       (matches-token?
                        chosen-license
                        (element-attribute package "data-licenses"))
                       (matches-choice?
                        chosen-redistribution
                        (element-attribute package "data-redistributable"))
                       (matches-token?
                        chosen-language
                        (element-attribute package "data-languages"))
                       (matches-token?
                        chosen-style
                        (element-attribute package "data-styles")))))
            (set-hidden! package (if matches 0 1))
            (loop (+ index 1) (+ visible (if matches 1 0))))))))

(define-foreign create-element
  "document" "createElement"
  (ref string) -> (ref extern))

(define-foreign element-text "element" "text" (ref extern) -> (ref string))

(define-foreign element-query
  "element" "query"
  (ref extern) (ref string) -> (ref extern))

(define-foreign element-has
  "element" "has"
  (ref extern) (ref string) -> i32)

(define-foreign set-disabled!
  "element" "setDisabled"
  (ref extern) i32 -> none)

(define-foreign set-attribute!
  "element" "setAttribute"
  (ref extern) (ref string) (ref string) -> none)

(define-foreign replace-children!
  "element" "replace"
  (ref extern) (ref extern) -> none)

(define-foreign clear-children! "element" "clear" (ref extern) -> none)

(define-foreign observe!
  "element" "observe"
  (ref extern) (ref extern) -> none)

(define-foreign json-parse "json" "parse" (ref string) -> (ref extern))

(define-foreign json-object
  "json" "object"
  (ref extern) (ref string) -> (ref extern))

(define-foreign json-text
  "json" "text"
  (ref extern) (ref string) -> (ref string))

(define-foreign json-has "json" "has" (ref extern) (ref string) -> i32)

(define-foreign current-url "browser" "url" -> (ref extern))

(define-foreign url-parameter
  "browser" "parameter"
  (ref extern) (ref string) (ref string) -> (ref string))

(define-foreign set-parameter!
  "browser" "setParameter"
  (ref extern) (ref string) (ref string) -> none)

(define-foreign delete-parameter!
  "browser" "deleteParameter"
  (ref extern) (ref string) -> none)

(define-foreign replace-url! "browser" "replaceURL" (ref extern) -> none)

(define-foreign on-history! "browser" "onHistory" (ref extern) -> none)

(define-foreign start-timer "browser" "timer" i32 (ref extern) -> i32)

(define-foreign clear-timer! "browser" "clearTimer" i32 -> none)

(define-foreign timestamp "browser" "now" -> (ref string))

(define-foreign fetch-json
  "browser" "fetchJSON"
  (ref string) (ref extern) (ref extern) -> (ref extern))

(define-foreign abort-request! "browser" "abort" (ref extern) -> none)

(define (each-node nodes proc)
  "Call PROC for each node in a browser collection."
  (let loop ((index 0))
    (unless (= index (collection-length nodes))
      (proc (collection-ref nodes index))
      (loop (+ index 1)))))

(define (remove-key key entries)
  "Return ENTRIES without the first matching KEY."
  (cond
   ((null? entries) '())
   ((equal? key (caar entries)) (cdr entries))
   (else (cons (car entries) (remove-key key (cdr entries))))))

(define filter-ids
  '("query"
    "vendor"
    "license-cost"
    "license"
    "redistribution"
    "language"
    "style"))

(define (restore-filters!)
  "Restore valid URL values, distinguishing default Chinese from all languages."
  (let ((url (current-url)))
    (for-each
     (lambda (id)
       (let* ((element (element-by-id id))
              (fallback (if (string=? id "language") "zh" ""))
              (value (url-parameter url id fallback))
              (valid? (string=? id "query")))
         (unless valid?
           (each-node
            (elements-by-selector (string-append "#" id " option"))
            (lambda (option)
              (when (string=? value (element-value option))
                (set! valid? #t)))))
         (set-value! element (if valid? value fallback))))
     filter-ids)))

(define manifests '())
(define pending '())
(define request-queue '())
(define active-requests 0)

(define (pump-requests!)
  "Start queued manifests within the limit and release completed slots."
  (when (and (< active-requests 4) (pair? request-queue))
    (let* ((url (car request-queue)) (timer 0))
      (set! request-queue (cdr request-queue))
      (set! active-requests (+ active-requests 1))
      (define (finish data)
        (clear-timer! timer)
        (set! active-requests (- active-requests 1))
        (let ((callbacks (cdr (assoc url pending))))
          (set! pending (remove-key url pending))
          (when data
            (set! manifests (cons (cons url data) manifests)))
          (for-each
           (lambda (callback)
             (if data ((car callback) data) ((cdr callback))))
           callbacks))
        (pump-requests!))
      (let ((request
             (fetch-json
              url
              (procedure->external (lambda (data) (finish data)))
              (procedure->external (lambda () (finish #f))))))
        (set! timer
              (start-timer
               30000
               (procedure->external (lambda () (abort-request! request))))))
      (pump-requests!))))

(define (request-manifest! url success failure)
  "Share cached or pending manifest requests between result callbacks."
  (let ((cached (assoc url manifests)) (waiting (assoc url pending)))
    (cond
     (cached (success (cdr cached)))
     (waiting (set-cdr! waiting (cons (cons success failure) (cdr waiting))))
     (else (set! pending
                 (cons (cons url (list (cons success failure))) pending))
           (set! request-queue (append request-queue (list url)))
           (pump-requests!)))))

;; Generations guard against stale callbacks after a selection changes.
(define-record-type <preview-state>
  (make-preview-state row slot retry-button generation selection visible?
                      timer image)
  preview-state?
  (row preview-row)
  (slot preview-slot)
  (retry-button preview-retry-button)
  (generation preview-generation set-preview-generation!)
  (selection preview-selection set-preview-selection!)
  (visible? preview-visible? set-preview-visible!)
  (timer preview-timer set-preview-timer!)
  (image preview-image set-preview-image!))

(define states '())
(define chosen-language "zh")
(define language-labels
  (json-parse (element-text (element-by-id "language-labels"))))

(define (preview-status! state message retry?)
  "Update the face status and retry control; hide empty success messages."
  (let ((status (element-query (preview-row state) "[data-preview-status]")))
    (set-text! status message)
    (set-hidden! status (if (string-null? message) 1 0))
    (set-hidden! (preview-retry-button state) (if retry? 0 1))))

(define (hide-preview! state)
  "Invalidate pending callbacks and hide the image for the previous selection."
  (clear-timer! (preview-timer state))
  (set-preview-generation! state (+ 1 (preview-generation state)))
  (when (preview-image state)
    (set-hidden! (preview-image state) 1))
  (set-preview-selection! state #f))

(define (load-preview-image! state sample label generation retry?)
  "Load SAMPLE into STATE, ignoring callbacks from an older GENERATION."
  (let ((image (create-element "img")))
    (define (current?) (= generation (preview-generation state)))
    (define (failed)
      (when (current?)
        (clear-timer! (preview-timer state))
        (set-hidden! image 1)
        (preview-status! state "预览图片加载失败或超时。" #t)))
    (set-attribute!
     image "alt"
     (string-append (element-attribute (preview-row state) "data-face-name")
                    "：" label
                    (if (string=? (json-text sample "kind") "characters")
                        "字表预览" "预览")))
    (set-attribute! image "width" (json-text sample "width"))
    (set-attribute! image "height" (json-text sample "height"))
    (set-attribute! image "style" "max-width: 100%; height: auto")
    (set-hidden! image 1)
    (on-event!
     image "load"
     (procedure->external
      (lambda ()
        (when (current?)
          (clear-timer! (preview-timer state))
          (set-hidden! image 0)
          (preview-status! state "" #f)))))
    (on-event! image "error" (procedure->external failed))
    (replace-children! (preview-slot state) image)
    (set-preview-image! state image)
    (set-preview-timer! state (start-timer 30000 (procedure->external failed)))
    (set-attribute!
     image "src"
     (string-append (json-text sample "url")
                    (if retry? (string-append "?retry=" (timestamp)) "")))))

(define (show-preview! state retry?)
  "Load the selected language for STATE and ignore stale asynchronous results."
  (unless (and (not retry?) (equal? (preview-selection state) chosen-language))
    (hide-preview! state)
    (let ((generation (preview-generation state)) (selected chosen-language))
      (define (current?) (= generation (preview-generation state)))
      (preview-status! state "正在加载预览图片……" #f)
      (request-manifest!
       (element-attribute (preview-row state) "data-samples-url")
       (lambda (data)
         (when (current?)
           (let* ((tag (if (string-null? selected)
                           (json-text data "defaultLanguage")
                           selected))
                  (samples (json-object data "samples"))
                  (label (json-text language-labels tag)))
             (set-preview-selection! state selected)
             (if (= 0 (json-has samples tag))
                 (begin
                   (clear-children! (preview-slot state))
                   (set-preview-image! state #f)
                   (preview-status! state
                                    (string-append "此款式暂无" label "预览。")
                                    #f))
                 (load-preview-image! state (json-object samples tag)
                                      label generation retry?)))))
       (lambda ()
         (when (current?)
           (set-preview-selection! state #f)
           (preview-status! state "预览索引加载失败或超时。" #t)))))))

(define (set-preview-language! value)
  "Invalidate old selections and load visible faces for VALUE."
  (set! chosen-language value)
  (for-each
   (lambda (state)
     (unless (equal? (preview-selection state) value)
       (hide-preview! state)
       (preview-status! state "等待加载所选语言的预览。" #f)
       (when (preview-visible? state)
         (show-preview! state #f))))
   states))

(define (save-filters!)
  "Persist filters in the URL and synchronize preview language selection."
  (let ((url (current-url)))
    (for-each
     (lambda (id)
       (let ((value (element-value (element-by-id id))))
         (cond
          ((and (string=? id "language") (string=? value "zh"))
           (delete-parameter! url id))
          ((or (string=? id "language") (not (string-null? value)))
           (set-parameter! url id value))
          (else (delete-parameter! url id)))))
     filter-ids)
    (replace-url! url))
  (set-preview-language! (element-value language)))

(define (changed!)
  "Apply the current form values to the catalog, URL and previews."
  (filter-packages!)
  (save-filters!))

(define (reset-filters!)
  "Clear all filters and restore the default Chinese selection."
  (for-each (lambda (id) (set-value! (element-by-id id) "")) filter-ids)
  (set-value! language "zh")
  (changed!))

(define (main)
  "Initialize catalog enhancement and register browser callbacks once."
  (restore-filters!)

  (filter-packages!)

  (each-node
   (elements-by-selector "[data-image-preview]")
   (lambda (row)
     (let* ((slot (element-query row "[data-preview-slot]"))
            (image (and (= 1 (element-has slot "img"))
                        (element-query slot "img")))
            (state (make-preview-state
                    row slot (element-query row "[data-preview-retry]")
                    0 #f #f 0 image)))
       (set! states (cons state states))
       (on-event!
        (preview-retry-button state)
        "click"
        (procedure->external (lambda () (show-preview! state #t))))
       (observe!
        row
        (procedure->external
         (lambda (visible)
           (set-preview-visible! state (= visible 1))
           (when (= visible 1)
             (show-preview! state #f))))))))

  (save-filters!)

  (on-event! query "input" (procedure->external changed!))

  (for-each
   (lambda (element) (on-event! element "change" (procedure->external
                                                  changed!)))
   (list vendor license-cost license redistribution language style))

  (on-event!
   (element-by-id "reset-filters")
   "click"
   (procedure->external reset-filters!))

  (on-history! (procedure->external (lambda () (restore-filters!) (changed!))))

  (each-node
   (elements-by-selector "[data-interactive]")
   (lambda (control) (set-disabled! control 0)))

  (set-text! (element-by-id "status") "字体目录已就绪。"))

(main)
