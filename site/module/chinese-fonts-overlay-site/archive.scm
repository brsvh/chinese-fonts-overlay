(define-module (chinese-fonts-overlay-site archive)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (chinese-fonts-overlay-site interface)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 regex)
  #:use-module (rnrs bytevectors)
  #:use-module (rnrs io ports)
  #:use-module (srfi srfi-1)
  #:export (pack-site unpack-site validate-release release-name))

(define maximum-size 1000000000)
(define root-files
  '("index.html" "licenses.html" "style.css" "bridge.js" "catalog.json"
    "fonts.css" "presentation.js" "manual.js"
    "previews.json" "main.wasm" "reflect.js" "reflect.wasm" "wtf8.wasm"
    "favicon.svg" "cc0.svg" "tsanger-license.pdf"
    "yuyang-regular.ttf" "yuyang-medium.ttf"
    "manual/index.html" "manual/chinese-fonts-overlay.info"))

(define (require condition message . arguments)
  "Raise MESSAGE with ARGUMENTS when a validation CONDITION is false."
  (unless condition (apply error message arguments)))

(define (matches? pattern value)
  "Match PATTERN against VALUE only when it is a string."
  (and (string? value) (regexp-exec (make-regexp pattern) value)))

(define (public-path? name)
  "Recognize a relative regular-file NAME permitted in the public archive."
  (or (member name root-files)
      (member name commercial-font-names)
      (matches? "^manual/[A-Za-z0-9_-]+\\.html$" name)
      (matches? "^assets/images/[0-9a-f]{64}\\.webp$" name)
      (matches? "^assets/previews/[0-9a-f]{64}\\.json$" name)))

(define (release-name manifest)
  "Return the immutable basename for a validated release MANIFEST."
  (string-append "site-" (jref manifest "source") "-"
                 (jref manifest "sha256")))

(define (validate-release manifest)
  "Validate the small release manifest before allocating or downloading data."
  (require (and (list? manifest)
                (every (lambda (entry) (and (pair? entry)
                                            (string? (car entry)))) manifest)
                (equal? (sort (map car manifest) string<?)
                        '("files" "schema" "sha256" "size" "source"
                          "unpackedSize")))
           "Invalid release manifest fields")
  (require (and (equal? (jref manifest "schema") 1)
                (matches? "^[0-9a-f]{40}$" (jref manifest "source"))
                (matches? "^[0-9a-f]{64}$" (jref manifest "sha256")))
           "Invalid release identity")
  (for-each
   (lambda (key)
     (let ((value (jref manifest key)))
       (require (and (exact-integer? value) (< 0 value maximum-size))
                "Invalid release size" key)))
   '("files" "size" "unpackedSize"))
  (require (<= (length root-files) (jref manifest "files") 100000)
           "Invalid release file count")
  manifest)

(define (public-files directory)
  "List allowed files in DIRECTORY, rejecting links and incomplete output."
  (define (walk relative)
    (let* ((path (if (string-null? relative) directory
                     (string-append directory "/" relative)))
           (info (lstat path)))
      (case (stat:type info)
        ((regular)
         (require (public-path? relative) "Unexpected public file" relative)
         (list relative))
        ((directory)
         (require (member relative '("" "manual" "assets" "assets/images"
                                     "assets/previews"))
                  "Unexpected public directory" relative)
         (append-map
          (lambda (name)
            (walk (if (string-null? relative) name
                      (string-append relative "/" name))))
          (scandir path (lambda (name) (not (member name '("." "..")))))))
        (else
         (error "Public output contains a link or special file" relative)))))
  (let ((files (sort (walk "") string<?)))
    (require (every (lambda (name) (member name files)) root-files)
             "Missing required public files")
    (let ((fonts (filter (lambda (name) (member name files))
                         commercial-font-names)))
      (require (or (null? fonts) (equal? fonts commercial-font-names))
               "Incomplete commercial interface fonts"))
    files))

(define (pack-site directory source destination)
  "Pack validated public output. DESTINATION must be a new owned directory."
  (require (matches? "^[0-9a-f]{40}$" source) "Invalid source revision")
  (let* ((files (public-files directory))
         (size (fold (lambda (file total)
                       (+ total (stat:size (stat (string-append directory
                                                                "/" file)))))
                     0 files)))
    (require (< 0 size maximum-size) "Website exceeds Pages size limit")
    (require (equal? source
                     (jref (read-json (string-append directory "/catalog.json"))
                           "sourceRevision"))
             "Catalog source revision differs from release")
    (for-each
     (lambda (asset)
       (let ((expected (getenv (cdr asset)))
             (actual (string-append directory "/" (car asset))))
         (require (and expected
                       (equal? (file-digest expected) (file-digest actual)))
                  "Interface asset differs from its declared input"
                  (car asset))))
     '(("yuyang-regular.ttf" . "UI_FONT_REGULAR")
       ("yuyang-medium.ttf" . "UI_FONT_MEDIUM")
       ("tsanger-license.pdf" . "UI_FONT_LICENSE")))
    (when (any (lambda (name) (member name files)) commercial-font-names)
      (let ((inputs (commercial-font-inputs (getenv "MB_TYPE_DIR"))))
        (require (pair? inputs) "MB_TYPE_DIR is required to verify webfonts")
        (for-each
         (lambda (entry)
           (require (equal? (file-digest (cdr entry))
                            (file-digest (string-append directory "/" (car entry))))
                    "Interface asset differs from its declared input"
                    (car entry)))
         inputs)))
    (mkdir destination)
    (catch #t
      (lambda ()
        (let ((list-file (string-append destination "/files"))
              (archive (string-append destination "/site.tar.gz")))
          (write-text list-file (string-append (string-join files "\n") "\n"))
          (run "tar" "--format=ustar" "--mtime=@0" "--owner=0" "--group=0"
               "--numeric-owner" "--mode=0644" "--no-recursion"
               "--hard-dereference"
               "--directory" directory
               "--create" "--gzip" "--file" archive "--files-from" list-file)
          (delete-file list-file)
          (let* ((manifest (validate-release
                            `(("schema" . 1) ("source" . ,source)
                              ("sha256" . ,(file-digest archive))
                              ("size" . ,(stat:size (stat archive)))
                              ("unpackedSize" . ,size)
                              ("files" . ,(length files)))))
                 (base (string-append destination "/" (release-name manifest))))
            (rename-file archive (string-append base ".tar.gz"))
            (write-json (string-append base ".json") manifest)
            manifest)))
      (lambda arguments
        (delete-tree destination)
        (apply throw arguments)))))

(define (header-string bytes start count)
  "Decode a NUL-terminated UTF-8 field within COUNT bytes at byte offset START."
  (let loop ((end start))
    (if (or (= end (+ start count)) (= 0 (bytevector-u8-ref bytes end)))
        (utf8->string (let ((part (make-bytevector (- end start))))
                        (bytevector-copy! bytes start part 0 (- end start))
                        part))
        (loop (+ end 1)))))

(define (octal-field header start count)
  "Read an octal number from COUNT bytes of HEADER at byte offset START."
  (let ((text (string-trim-both (header-string header start count))))
    (require (matches? "^[0-7]+$" text) "Invalid tar numeric field")
    (string->number text 8)))

(define (read-exactly port count)
  "Read COUNT bytes from PORT, rejecting premature end of the archive."
  (let ((bytes (get-bytevector-n port count)))
    (require (and (bytevector? bytes) (= (bytevector-length bytes) count))
             "Truncated site archive")
    bytes))

(define (zero-block? bytes)
  "Return true when every byte in the bytevector BYTES is zero."
  (every zero? (bytevector->u8-list bytes)))

(define (extract-files port destination manifest)
  "Extract bounded ustar data from PORT into the owned DESTINATION directory."
  ;; Only our regular-file ustar subset is accepted; no links, PAX overrides,
  ;; absolute paths, directories, duplicate entries or executable file modes.
  (let ((seen (make-hash-table)))
    (let loop ((count 0) (total 0))
      (let ((header (read-exactly port 512)))
        (if (zero-block? header)
            (begin
              (require (and (= total (jref manifest "unpackedSize"))
                            (= count (jref manifest "files"))
                            (every (lambda (name) (hash-ref seen name))
                                   root-files))
                       "Site archive contents differ from manifest")
              (require (zero-block? (read-exactly port 512))
                       "Invalid tar end marker")
              ;; Permit record padding, but never drain unbounded output.
              (let ((tail (get-bytevector-n port 10241)))
                (require (or (eof-object? tail)
                             (and (<= (bytevector-length tail) 10240)
                                  (zero-block? tail)))
                         "Unexpected archive trailer")))
            (let* ((name (header-string header 0 100))
                   (size (octal-field header 124 12))
                   (checksum (octal-field header 148 8)))
              (require (and (public-path? name) (not (hash-ref seen name))
                            (equal? (header-string header 257 6) "ustar")
                            (string-null? (header-string header 345 155))
                            (string-null? (header-string header 157 100))
                            (= (bytevector-u8-ref header 156) 48)
                            (= (logand (octal-field header 100 8) #o7111) 0))
                       "Unsafe site archive entry" name)
              (do ((i 148 (+ i 1))) ((= i 156))
                (bytevector-u8-set! header i 32))
              (require (= checksum (apply + (bytevector->u8-list header)))
                       "Invalid tar checksum")
              (require (and (< (+ total size) maximum-size)
                            (<= (+ total size) (jref manifest "unpackedSize"))
                            (< count (jref manifest "files")))
                       "Site archive exceeds declared limits")
              (let ((path (string-append destination "/" name)))
                (mkdir-p (dirname path))
                (call-with-output-file path
                  (lambda (output)
                    (let copy ((remaining size))
                      (unless (zero? remaining)
                        (let* ((count (min remaining 65536))
                               (bytes (read-exactly port count)))
                          (put-bytevector output bytes)
                          (copy (- remaining count)))))))
                (chmod path #o644))
              (let ((padding (modulo (- size) 512)))
                (unless (zero? padding) (read-exactly port padding)))
              (hash-set! seen name #t)
              (loop (+ count 1) (+ total size))))))))

(define (unpack-site archive manifest destination)
  "Validate and extract into a new directory; remove partial output on error."
  (validate-release manifest)
  (require (and (= (stat:size (lstat archive)) (jref manifest "size"))
                (equal? (file-digest archive) (jref manifest "sha256")))
           "Site archive digest or size mismatch")
  (mkdir destination)
  (let ((port (open-pipe* OPEN_READ "gzip" "--decompress" "--stdout" archive))
        (success? #f))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (extract-files port destination manifest)
          (require (zero? (close-pipe port)) "Invalid gzip archive")
          (public-files destination)
          (require (equal? (jref manifest "source")
                           (jref (read-json
                                  (string-append destination "/catalog.json"))
                                 "sourceRevision"))
                   "Catalog source revision differs from release")
          (set! success? #t))
        (lambda ()
          (unless (port-closed? port) (close-pipe port))
          (unless success? (delete-tree destination))))))
