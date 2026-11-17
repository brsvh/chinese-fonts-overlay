(import (scheme base)
        (example action-owner)
        (fibers promises)
        (hoot ffi))

(define-foreign copy-link "action" "copyLink" (ref string) -> (ref extern))
(define-foreign current-link "action" "currentLink" -> (ref string))
(define-foreign render-state! "action" "render" (ref string) (ref string) -> none)

(define-values (begin! settle! dispose! current-phase) (make-action-owner))

(define (run-action resolved rejected)
  "Copy the current link once; publish an outcome only for the accepted token."
  (call-with-async-result
   resolved rejected
   (lambda ()
     (let ((token (begin!)))
       (when token
         (render-state! "pending" "Copying link")
         (guard (exception
                 (else
                  (when (settle! token 'failed)
                    (render-state! "failed" "Copy failed; use the ordinary link"))))
           (await (copy-link (current-link)))
           (when (settle! token 'succeeded)
             (render-state! "succeeded" "Link copied")))))
     (symbol->string (current-phase)))))

(define (dispose-action)
  "Invalidate pending results without claiming to cancel the host operation."
  (dispose!))

(values run-action dispose-action)
