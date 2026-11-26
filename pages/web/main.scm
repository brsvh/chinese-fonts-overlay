(use-modules (catalog filters) (catalog host) (catalog manifests)
             (hoot ffi) (srfi srfi-9) (srfi srfi-13))

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

(define preview-states '())

(define chosen-languages '())

(define language-labels #f)

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
    (if loading?
        (let ((spinner (create-element "span")) (label (create-element "span")))
          (clear-children! status)
          (set-attribute! spinner "class" "loading loading-spinner loading-sm")
          (set-attribute! spinner "aria-hidden" "true")
          (set-text! label message)
          (append-child! status spinner)
          (append-child! status label))
        (set-text! status message))
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
          (let ((tag (car tags)))
            (if (= 0 (json-has samples tag))
                (loop (cdr tags) groups)
                (let* ((sample (json-object samples tag))
                       (url (json-text sample "url"))
                       (found (assoc url groups)))
                  (if found
                      (begin
                        (set-cdr! found (append (cdr found) (list tag)))
                        (loop (cdr tags) groups))
                      (loop (cdr tags)
                            (append groups (list (list url tag))))))))))))

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
              (caption #f)
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
               (when caption (set-hidden! caption (if success? 0 1)))
               (set-hidden! box (if success? 0 1))
               (when (= remaining 0)
                 (preview-status!
                  state
                  (if failed? "部分预览图片加载失败或超时。" "")
                  failed? #f)))))
         (unless cover?
           (let ((many? (> (length tags) 3)))
             (set! caption (create-element (if many? "details" "p")))
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
             (set-hidden! caption 1)
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
  (sync-filters! save?)
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
          (set! chosen-languages (apply-filters! language-labels))
          (resize-previews!)
          (set! waiting-previews (nearby-previews 0))
          (load-nearby-previews!)
          (set! change-applied? #t)
          (finish-change!)))))))

(define (copy-package! button)
  "Copy the exact package attribute and expose success or actionable failure."
  (let ((name (element-attribute button "data-copy"))
        (status (element-by-id "status")))
    (set-disabled! button 1)
    (copy-text!
     name
     (procedure->external
      (lambda ()
        (set-disabled! button 0)
        (set-attribute! button "data-copied" "true")
        (set-attribute! button "title" "已复制")
        (set-text! status "")
        (set-hidden! status 1)
        (set-text! (element-by-id "copy-status") (string-append "已复制 " name))))
     (procedure->external
      (lambda ()
        (set-disabled! button 0)
        (set-attribute! button "data-copied" "false")
        (set-attribute! button "title" "复制完整包名")
        (set-text! (element-by-id "copy-status") "复制失败，请选择包名后手动复制。")
        (set-text! status "复制失败，请选择包名后手动复制。")
        (set-hidden! status 0))))))

(define (main)
  "Initialize once, preserving native links and disclosures on failure."
  (set! language-labels
        (json-parse (element-text (element-by-id "language-labels"))))
  (initialize-filters! schedule-filter-update!)
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
