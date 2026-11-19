(use-modules (hoot ffi) (srfi srfi-9) (srfi srfi-13))

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

(define (fit-option-label! label)
  "Keep balanced lines at the largest fitting size, in 1/32 em increments."
  (define (set-size! steps)
    (set-style! label "font-size"
                (string-append (number->string (/ steps 32.0)) "em")))
  (set-size! 32)
  (unless (= 1 (text-fits? label))
    (let loop ((low 1) (high 31))
      (if (>= low high)
          (set-size! low)
          (let ((middle (quotient (+ low high 1) 2)))
            (set-size! middle)
            (if (= 1 (text-fits? label))
                (loop middle high)
                (loop low (- middle 1))))))))

(define (contains-text? text query)
  "Match QUERY at Scheme character boundaries; Hoot lacks string-contains."
  (let ((limit (- (string-length text) (string-length query))))
    (let loop ((start 0))
      (and (<= start limit)
           (or (string=?
                query
                (substring text start (+ start (string-length query))))
               (loop (+ start 1)))))))

(define (remove-key key entries)
  "Return ENTRIES without KEY, retaining order and other associations."
  (filter (lambda (entry) (not (equal? key (car entry)))) entries))

(define-record-type <facet>
  (make-facet key options all defaults)
  facet?
  (key facet-key)
  (options facet-options)
  (all facet-all)
  (defaults facet-defaults))

(define facets '())

(define packages '())

(define preview-states '())

(define chosen-languages '())

(define language-labels #f)

(define (facet-selection facet)
  "Return checked values in FACET's stable option order."
  (map element-value
       (filter (lambda (option) (= 1 (checked? option)))
               (facet-options facet))))

(define (set-facet-selection! facet values)
  "Set FACET selection to VALUES, including options in collapsed sections."
  (for-each
   (lambda (option)
     (set-checked! option (if (member (element-value option) values) 1 0)))
   (facet-options facet)))

(define (sync-select-all! facet)
  "Reflect complete, partial and empty selection in the heading checkbox."
  (let ((count (length (facet-selection facet)))
        (total (length (facet-options facet))))
    (set-checked! (facet-all facet) (if (= count total) 1 0))
    (set-indeterminate!
     (facet-all facet)
     (if (and (> count 0) (< count total)) 1 0))))

(define (restore-filters! defaults?)
  "Restore defaults or URL state; star means all, empty means none."
  (let ((url (current-url)))
    (for-each
     (lambda (facet)
       (let* ((fallback (string-join (facet-defaults facet) ","))
              (value (if defaults?
                         fallback
                         (url-parameter url (facet-key facet) fallback)))
              (choices (map element-value (facet-options facet)))
              (values
               (if (string=? value "*")
                   choices
                   (filter
                    (lambda (key) (member key choices))
                    (string-split value #\,)))))
         (set-facet-selection! facet values)
         (sync-select-all! facet)))
     facets)
    (set-value!
     (element-by-id "query")
     (if defaults? "" (url-parameter url "query" "")))
    (set-checked!
     (element-by-id "embedding")
     (if (and (not defaults?)
              (string=? (url-parameter url "embedding" "") "true"))
         1
         0))
    (set-value!
     (element-by-id "sort")
     (if (and (not defaults?) (string=? (url-parameter url "sort" "") "name"))
         "name"
         "default"))
    (let* ((size (and (not defaults?)
                      (string->number (url-parameter url "size" "66"))))
           (valid? (and (integer? size) (<= 36 size 96) (even? size))))
      (set-value!
       (element-by-id "size")
       (if valid? (number->string size) "66")))))

(define (save-filters!)
  "Push a shareable state, omitting defaults without conflating all and none."
  (let ((url (current-url)))
    (for-each
     (lambda (facet)
       (let ((values (facet-selection facet)))
         (if (equal? values (facet-defaults facet))
             (delete-parameter! url (facet-key facet))
             (set-parameter!
              url
              (facet-key facet)
              (if (= (length values) (length (facet-options facet)))
                  "*"
                  (string-join values ","))))))
     facets)
    (for-each
     (lambda (entry)
       (if (string-null? (cdr entry))
           (delete-parameter! url (car entry))
           (set-parameter! url (car entry) (cdr entry))))
     (list (cons "query" (element-value (element-by-id "query")))
           (cons "embedding"
                 (if (= 1 (checked? (element-by-id "embedding"))) "true" ""))
           (cons "sort"
                 (if (string=? (element-value (element-by-id "sort")) "name")
                     "name"
                     ""))
           (cons "size"
                 (let ((size (element-value (element-by-id "size"))))
                   (if (string=? size "66") "" size)))))
    (push-url! url)))

(define (package-matches? row selections text embedding?)
  "Match any selected value within each group and require every group to match."
  (and (contains-text?
        (string-downcase (element-attribute row "data-search"))
        text)
       (or (not embedding?)
           (string=? (element-attribute row "data-embedding") "true"))
       (let loop ((rest selections))
         (or (null? rest)
             (and (let ((actual
                         (string-split
                          (element-attribute
                           row
                           (string-append "data-" (caar rest)))
                          #\space)))
                    (let any ((values (cdar rest)))
                      (and (pair? values)
                           (or (member (car values) actual) (any (cdr values))))))
                  (loop (cdr rest)))))))

(define (filter-packages!)
  "Apply current filters and sorting without replacing package disclosures."
  (let* ((selections
          (map (lambda (facet) (cons (facet-key facet) (facet-selection facet)))
               facets))
         (text (string-downcase
                (string-trim-both (element-value (element-by-id "query")))))
         (embedding? (= 1 (checked? (element-by-id "embedding"))))
         (order (if (string=? (element-value (element-by-id "sort")) "name")
                    (stable-sort
                     packages
                     (lambda (a b)
                       (string<?
                        (element-attribute a "data-name")
                        (element-attribute b "data-name"))))
                    packages))
         (visible 0))
    (for-each
     (lambda (row)
       (let ((show? (package-matches? row selections text embedding?)))
         (set-hidden! row (if show? 0 1))
         (when show? (set! visible (+ visible 1))))
       (append-child! (element-by-id "packages") row))
     order)
    (set-text!
     (element-by-id "result-count")
     (string-append
      (number->string visible)
      " / "
      (number->string (length packages))
      " 个字体包"))
    (set-hidden! (element-by-id "empty-results") (if (= visible 0) 0 1))))

(define manifests '())

(define pending '())

(define request-queue '())

(define active-requests 0)

(define (pump-requests!)
  "Start queued manifests within a four-request limit, with bounded timeouts."
  (when (and (< active-requests 4) (pair? request-queue))
    (let* ((url (car request-queue)) (timer 0))
      (define (finish data)
        (clear-timer! timer)
        (set! active-requests (- active-requests 1))
        (let ((callbacks (cdr (assoc url pending))))
          (set! pending (remove-key url pending))
          (when data (set! manifests (cons (cons url data) manifests)))
          (for-each
           (lambda (callback)
             (if data ((car callback) data) ((cdr callback))))
           callbacks))
        (pump-requests!))
      (set! request-queue (cdr request-queue))
      (set! active-requests (+ active-requests 1))
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
  "Share cached or pending manifests between cover and expanded preview users."
  (let ((cached (assoc url manifests)) (waiting (assoc url pending)))
    (cond
     (cached (success (cdr cached)))
     (waiting (set-cdr! waiting (cons (cons success failure) (cdr waiting))))
     (else (set! pending
                 (cons (cons url (list (cons success failure))) pending))
           (set! request-queue (append request-queue (list url)))
           (pump-requests!)))))

(define-record-type <preview-state>
  (make-preview-state row slot retry generation selection ready? timers)
  preview-state?
  (row preview-row)
  (slot preview-slot)
  (retry preview-retry)
  (generation preview-generation set-preview-generation!)
  (selection preview-selection set-preview-selection!)
  (ready? preview-ready? set-preview-ready!)
  (timers preview-timers set-preview-timers!))

(define change-generation 0)
(define change-applied? #f)
(define finishing-change? #f)
(define presentation-ready? #f)
(define waiting-previews '())

(define (finish-change!)
  "Reveal the latest result set once its visible previews have settled."
  (when (and change-applied? presentation-ready? (not finishing-change?)
             (null? (filter (lambda (state) (not (preview-ready? state)))
                            waiting-previews)))
    (set! finishing-change? #t)
    (let ((generation change-generation))
      (after-paint!
       (procedure->external
        (lambda ()
          (when (= generation change-generation)
            (set! change-applied? #f)
            (set-attribute! (element-by-id "preview-content") "aria-busy" "false")
            (set-inert! (element-by-id "preview-content") 0)
            (set-hidden! (element-by-id "preview-loading") 1)
            (finish-startup!))))))))

(define (preview-status! state message retry? loading?)
  "Expose a face's loading, missing or failure state and its retry action."
  (let ((status (element-query (preview-row state) "[data-preview-status]")))
    (set-text! status message)
    (when loading?
      (let ((spinner (create-element "span")) (label (create-element "span")))
        (clear-children! status)
        (set-attribute! spinner "class" "loading loading-spinner loading-sm")
        (set-attribute! spinner "aria-hidden" "true")
        (set-text! label message)
        (append-child! status spinner)
        (append-child! status label)))
    (set-hidden! status (if (string-null? message) 1 0))
    (set-hidden! (preview-retry state) (if retry? 0 1))
    (set-preview-ready! state (not loading?))
    (finish-change!)))

(define (invalidate-preview! state)
  "Invalidate callbacks and remove images belonging to a previous selection."
  (for-each clear-timer! (preview-timers state))
  (set-preview-timers! state '())
  (set-preview-generation! state (+ 1 (preview-generation state)))
  (set-preview-selection! state #f)
  (set-preview-ready! state #f)
  (clear-children! (preview-slot state)))

(define (sample-groups data languages cover?)
  "Group LANGUAGES sharing an image; a cover shows only the first match."
  (let ((samples (json-object data "samples")))
    (let loop ((tags languages) (groups '()))
      (if (or (null? tags) (and cover? (pair? groups)))
          groups
          (let* ((tag (car tags))
                 (sample (json-object samples tag))
                 (url (json-text sample "url"))
                 (found (assoc url groups)))
            (cond
             ((= 0 (json-has samples tag)) (loop (cdr tags) groups))
             (found (set-cdr! found (append (cdr found) (list tag)))
                    (loop (cdr tags) groups))
             (else (loop (cdr tags) (append groups (list (list url tag)))))))))))

(define (show-images! state data groups generation retry?)
  "Load selected images, keeping successes and reporting partial failures."
  (let ((remaining (length groups))
        (failed? #f)
        (cover?
         (string=?
          (element-attribute (preview-row state) "data-image-preview")
          "cover")))
    (define (current?) (= generation (preview-generation state)))
    (for-each
     (lambda (group)
       (let* ((tags (cdr group))
              (sample (json-object (json-object data "samples") (car tags)))
              (labels
               (string-join
                (map (lambda (tag) (json-text language-labels tag)) tags)
                "、"))
              (box (create-element "div"))
              (image (create-element "img"))
              (timer 0)
              (settled? #f))
         (define (finish success?)
           (unless settled?
             (set! settled? #t)
             (clear-timer! timer)
             (when (current?)
               (set! remaining (- remaining 1))
               (unless success? (set! failed? #t))
               (set-hidden! box (if success? 0 1))
               (when (= remaining 0)
                 (preview-status!
                  state
                  (if failed? "部分预览图片加载失败或超时。" "")
                  failed? #f)))))
         (unless cover?
           (let* ((many? (> (length tags) 3))
                  (caption (create-element (if many? "details" "p"))))
             (set-attribute! caption "class" "sample-language")
             (if many?
                 (let ((summary (create-element "summary"))
                       (text (create-element "p")))
                   (set-text!
                    summary
                    (string-append
                     (json-text language-labels (car tags))
                     "等 "
                     (number->string (length tags))
                     " 种语言"))
                   (append-child! caption summary)
                   (set-text! text labels)
                   (append-child! caption text))
                 (set-text! caption labels))
             (append-child! (preview-slot state) caption)))
         (set-attribute! box "class" "sample")
         (set-attribute! box "tabindex" "0")
         (set-attribute! box "role" "region")
         (set-attribute! box "aria-label" "字体预览，可横向滚动")
         (set-attribute!
          image
          "alt"
          (string-append
           (element-attribute (preview-row state) "data-face-name")
           "："
           labels
           "，"
           (json-text sample "text")))
         (set-attribute! image "width" (json-text sample "width"))
         (set-attribute! image "height" (json-text sample "height"))
         (set-hidden! box 1)
         (listen! image "load" (lambda () (finish #t)))
         (listen! image "error" (lambda () (finish #f)))
         (append-child! box image)
         (append-child! (preview-slot state) box)
         (set! timer
               (start-timer
                30000
                (procedure->external (lambda () (finish #f)))))
         (set-preview-timers! state (cons timer (preview-timers state)))
         (set-attribute!
          image
          "src"
          (string-append
           (car group)
           (if retry? (string-append "?retry=" (timestamp)) "")))))
     groups)))

(define (show-preview! state retry?)
  "Render selected languages, ignoring stale manifest and image replies."
  (unless
      (and (not retry?) (equal? (preview-selection state) chosen-languages))
    (invalidate-preview! state)
    (let ((generation (preview-generation state)) (selection chosen-languages))
      (set-preview-selection! state selection)
      (preview-status! state "正在加载预览图片…" #f #t)
      (request-manifest!
       (element-attribute (preview-row state) "data-samples-url")
       (lambda (data)
         (when (= generation (preview-generation state))
           (set-preview-selection! state selection)
           (let ((groups
                  (sample-groups
                   data selection
                   (string=?
                    (element-attribute
                     (preview-row state)
                     "data-image-preview")
                    "cover"))))
             (if (null? groups)
                 (preview-status! state "此款式暂无所选语言样图。" #f #f)
                 (show-images! state data groups generation retry?)))))
       (lambda ()
         (when (= generation (preview-generation state))
           (preview-status! state "预览索引加载失败或超时。" #t #f)))))))

(define (update-preview-language!)
  "Read the language selection and update its badge before loading previews."
  (let* ((facet (car facets)) (values (facet-selection facet)))
    (set-text!
     (element-by-id "current-language")
     (cond
      ((null? values) "未选择语言")
      ((= (length values) (length (facet-options facet))) "全部语言")
      (else (string-join
             (map (lambda (tag) (json-text language-labels tag)) values)
             "、"))))
    (set! chosen-languages values)))

(define (resize-previews!)
  "Set the actual image height; overflow remains horizontally scrollable."
  (let ((value (element-value (element-by-id "size"))))
    (set-style!
     (element-by-id "packages")
     "--sample"
     (string-append value "px"))
    (set-text! (element-by-id "size-value") value)))

(define (nearby-previews margin)
  "Return rendered previews within MARGIN pixels of the viewport."
  (filter (lambda (state) (= 1 (in-viewport? (preview-row state) margin)))
          preview-states))

(define (load-nearby-previews!)
  "Load nearby covers or expanded faces, including just-opened disclosures."
  (for-each (lambda (state) (show-preview! state #f)) (nearby-previews 500)))

(define (schedule-filter-update! save?)
  "Paint a loading state before applying only the newest filter selection."
  (for-each sync-select-all! facets)
  (when save? (save-filters!))
  (set! change-generation (+ 1 change-generation))
  (set! change-applied? #f)
  (set! finishing-change? #f)
  (set! waiting-previews '())
  (set-attribute! (element-by-id "preview-content") "aria-busy" "true")
  (set-inert! (element-by-id "preview-content") 1)
  (set-hidden! (element-by-id "preview-loading") 0)
  (let ((generation change-generation))
    (after-paint!
     (procedure->external
      (lambda ()
        (when (= generation change-generation)
          (filter-packages!)
          (update-preview-language!)
          (resize-previews!)
          (set! waiting-previews (nearby-previews 0))
          (load-nearby-previews!)
          (set! change-applied? #t)
          (finish-change!)))))))

(define (copy-package! button)
  "Copy the exact package attribute and expose success or actionable failure."
  (let ((name (element-attribute button "data-copy")))
    (set-disabled! button 1)
    (copy-text!
     name
     (procedure->external
      (lambda ()
        (set-disabled! button 0)
        (set-attribute! button "data-copied" "true")
        (set-attribute! button "title" "已复制")
        (set-text! (element-by-id "copy-status") (string-append "已复制 " name))))
     (procedure->external
      (lambda ()
        (set-disabled! button 0)
        (set-text! (element-by-id "copy-status") "复制失败，请选择包名后手动复制。")
        (set-text! (element-by-id "status") "复制失败，请选择包名后手动复制。")
        (set-hidden! (element-by-id "status") 0))))))

(define (main)
  "Initialize once, preserving native links and disclosures on failure."
  (set! packages (nodes "#packages > article"))
  (set! language-labels
        (json-parse (element-text (element-by-id "language-labels"))))
  (set! facets
        (map (lambda (group)
               (let* ((key (element-attribute group "data-facet"))
                      (facet (make-facet
                              key
                              (nodes (string-append "[data-choice='" key "']"))
                              (element-query group "[data-select-all]")
                              (string-split
                               (element-attribute group "data-default")
                               #\,))))
                 (listen!
                  (facet-all facet)
                  "change"
                  (lambda ()
                    (set-facet-selection!
                     facet
                     (if (= 1 (checked? (facet-all facet)))
                         (map element-value (facet-options facet))
                         '()))
                    (schedule-filter-update! #t)))
                 (for-each
                  (lambda (option)
                    (listen! option "change"
                             (lambda () (schedule-filter-update! #t))))
                  (facet-options facet))
                 facet))
             (nodes "[data-facet]")))
  (restore-filters! #f)
  (for-each
   (lambda (row)
     (let ((state (make-preview-state
                   row
                   (element-query row "[data-preview-slot]")
                   (element-query row "[data-preview-retry]")
                   0
                   #f
                   #f
                   '())))
       (set! preview-states (cons state preview-states))
       (listen!
        (preview-retry state)
        "click"
        (lambda () (show-preview! state #t)))
       (observe!
        row
        (procedure->external
         (lambda (visible)
           (when (and (= visible 1) (pair? chosen-languages)
                      (= 1 (in-viewport? row 500)))
             (show-preview! state #f)))))))
   (nodes "[data-image-preview]"))
  (set! preview-states (reverse preview-states))
  (for-each
   (lambda (details) (listen! details "toggle" load-nearby-previews!))
   (nodes ".face-list"))
  (for-each
   (lambda (button)
     (listen!
      button
      "click"
      (lambda ()
        (let* ((open? (string=?
                       (element-attribute button "aria-expanded")
                       "false"))
               (extra (element-by-id
                       (element-attribute button "aria-controls"))))
          (set-hidden! extra (if open? 0 1))
          (set-attribute! button "aria-expanded" (if open? "true" "false"))
          (set-text! (element-query button "span") (if open? "收起" "展开"))))))
   (nodes "[data-facet-toggle]"))
  (for-each
   (lambda (button)
     (listen! button "click" (lambda () (copy-package! button))))
   (nodes "[data-copy]"))
  (listen! (element-by-id "query") "input"
           (lambda () (schedule-filter-update! #f)))
  (listen! (element-by-id "query") "change" save-filters!)
  (listen! (element-by-id "size") "input" resize-previews!)
  (listen! (element-by-id "size") "change" save-filters!)
  (for-each
   (lambda (id)
     (listen! (element-by-id id) "change"
              (lambda () (schedule-filter-update! #t))))
   '("embedding" "sort"))
  (listen!
   (element-by-id "reset-filters")
   "click"
   (lambda () (restore-filters! #t) (schedule-filter-update! #t)))
  (listen!
   (element-by-id "sidebar-toggle")
   "click"
   (lambda ()
     (let* ((button (element-by-id "sidebar-toggle"))
            (value (if (string=?
                        (element-attribute button "aria-expanded")
                        "true")
                       "false"
                       "true")))
       (set-attribute! button "aria-expanded" value)
       (set-attribute! (element-by-id "sidebar") "data-open" value))))
  (on-history!
   (procedure->external
    (lambda () (restore-filters! #f) (schedule-filter-update! #f))))
  (for-each
   (lambda (control) (set-disabled! control 0))
   (nodes "[data-interactive]"))
  (set-hidden! (element-by-id "status") 1)
  (on-presentation-ready!
   (procedure->external
    (lambda ()
      (for-each
       (lambda (option)
         (let ((label (element-query option "span")))
           (observe-size!
            option (procedure->external
                    (lambda () (fit-option-label! label))))))
       (nodes ".facet-chip, .check-option"))
      (set! presentation-ready? #t)
      (finish-change!))))
  (schedule-filter-update! #f))

(main)
