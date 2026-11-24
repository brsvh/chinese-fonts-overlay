(define-module (catalog manifests)
  #:use-module (catalog host)
  #:use-module (hoot ffi)
  #:export (request-manifest!))

(define (remove-key key entries)
  "Return ENTRIES without KEY, retaining order and other associations."
  (filter (lambda (entry) (not (equal? key (car entry)))) entries))

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
