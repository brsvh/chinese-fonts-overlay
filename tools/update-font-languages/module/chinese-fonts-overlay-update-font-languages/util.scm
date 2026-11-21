(define-module (chinese-fonts-overlay-update-font-languages util)
  #:use-module (json)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:export (jref
            jarray
            read-text
            write-text
            write-json
            mkdir-p
            delete-tree
            files-under
            run
            capture
            temporary-directory
            atomic-write))

(define* (jref object key #:optional (fallback #f))
  "Read KEY from a JSON object alist, or return FALLBACK."
  (let ((entry (assoc key object)))
    (if entry (cdr entry) fallback)))

(define (jarray value)
  "Return a list view of a JSON array."
  (if (vector? value) (vector->list value) value))

(define (write-json file value)
  "Write VALUE as UTF-8 JSON followed by a newline."
  (write-text file (string-append (scm->json-string value) "\n")))

(define (read-text file)
  "Read FILE as UTF-8 text."
  (call-with-input-file
      file
    (lambda (port) (set-port-encoding! port "UTF-8") (get-string-all port))))

(define (write-text file text)
  "Replace FILE with UTF-8 TEXT."
  (call-with-output-file
      file
    (lambda (port) (set-port-encoding! port "UTF-8") (display text port))))

(define (mkdir-p path)
  "Create PATH and any missing parent directories."
  (unless (file-exists? path)
    (let ((parent (dirname path)))
      (unless (equal? parent path)
        (mkdir-p parent)))
    (mkdir path)))

(define (delete-tree path)
  "Remove the owned tree at PATH without following directory symlinks."
  (when (or (file-exists? path)
            (false-if-exception (eq? 'symlink (stat:type (lstat path)))))
    (if (eq? 'directory (stat:type (lstat path)))
        (begin
          (for-each
           (lambda (name) (delete-tree (string-append path "/" name)))
           (scandir path (lambda (name) (not (member name '("." ".."))))))
          (rmdir path))
        (delete-file path))))

(define (files-under path)
  "List files recursively, following font-directory symlinks."
  (if (not (file-exists? path))
      '()
      (append-map
       (lambda (name)
         (let ((file (string-append path "/" name)))
           (if (eq? 'directory (stat:type (stat file)))
               (files-under file)
               (list file))))
       (scandir path (lambda (name) (not (member name '("." ".."))))))))

(define (run . args)
  "Execute the argument vector ARGS and fail on a nonzero exit status."
  (let ((status (apply system* args)))
    (unless (zero? status)
      (error "Command failed" args status))))

(define (capture . args)
  "Capture UTF-8 stdout from ARGS; propagate a nonzero exit status."
  (let* ((port (apply open-pipe* OPEN_READ args))
         (text (begin (set-port-encoding! port "UTF-8") (get-string-all port)))
         (status (close-pipe port)))
    (unless (zero? status)
      (error "Command failed" args status))
    text))

(define (temporary-directory parent)
  "Create and return a private temporary directory under PARENT."
  (mkdir-p parent)
  (mkdtemp (string-append parent "/.font-languages-XXXXXX")))

(define (atomic-write file writer)
  "Replace FILE on success, preserving its permissions when it already exists."
  (mkdir-p (dirname file))
  (let* ((mode (and (file-exists? file) (stat:perms (stat file))))
         (port (mkstemp (string-append file ".XXXXXX")))
         (temporary (port-filename port)))
    (close-port port)
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (writer temporary)
          (when mode (chmod temporary mode))
          (rename-file temporary file))
        (lambda () (when (file-exists? temporary)
                     (delete-file temporary))))))
