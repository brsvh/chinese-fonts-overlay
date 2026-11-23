(use-modules (chinese-fonts-overlay-site archive)
             (chinese-fonts-overlay-site interface)
             (chinese-fonts-overlay-site util)
             (ice-9 match)
             (srfi srfi-1)
             (srfi srfi-64))

(define root (temporary-directory "/tmp"))
(define source (make-string 40 #\a))
(define public (string-append root "/public"))
(mkdir public)
(mkdir (string-append public "/manual"))
(for-each (lambda (name) (write-text (string-append public "/" name) name))
          '("index.html" "licenses.html" "style.css" "bridge.js" "catalog.json"
            "fonts.css" "presentation.js" "manual.js"
            "previews.json" "main.wasm" "reflect.js" "reflect.wasm" "wtf8.wasm"
            "favicon.svg" "cc0.svg" "tsanger-license.pdf"
            "yuyang-regular.ttf" "yuyang-medium.ttf"
            "manual/index.html" "manual/chinese-fonts-overlay.info"
            "manual/Installation.html"))
(write-json (string-append public "/catalog.json")
            `(("sourceRevision" . ,source)))
(chmod (string-append public "/index.html") #o755)
(mkdir-p (string-append public "/assets/previews"))
(write-json (string-append public "/assets/previews/"
                           (make-string 64 #\b) ".json")
            '(("samples" . #())))
(for-each (lambda (asset)
            (setenv (cdr asset) (string-append public "/" (car asset))))
          '(("yuyang-regular.ttf" . "UI_FONT_REGULAR")
            ("yuyang-medium.ttf" . "UI_FONT_MEDIUM")
            ("tsanger-license.pdf" . "UI_FONT_LICENSE")))

(define (failure-message thunk)
  "Return the diagnostic from THUNK's expected content-validation failure."
  (catch 'misc-error thunk
         (lambda (key procedure message arguments . rest)
           (apply format #f message arguments))))

(test-begin "site-archive")
(define runner (test-runner-current))
(dynamic-wind
    (lambda () #t)
    (lambda ()
      (let* ((release (string-append root "/release"))
             (manifest (pack-site public source release))
             (archive (string-append release "/" (release-name manifest)
                                     ".tar.gz"))
             (output (string-append root "/extracted")))
        (unpack-site archive manifest output)
        (test-assert "Round-trip public files with normalized permissions"
                     (and (equal? (map file-digest (files-under public))
                                  (map file-digest (files-under output)))
                          (= #o644 (stat:perms (stat (string-append output "/index.html"))))))
        (test-assert "Reject corrupt archive before extraction"
                     (string-contains
                      (failure-message
                       (lambda () (unpack-site archive
                                               (jset manifest "sha256"
                                                     (make-string 64 #\0))
                                               (string-append root "/bad"))))
                      "digest or size mismatch"))
        ;; Byte fixtures exercise packaging without requiring purchased fonts.
        (let* ((library (string-append root "/library"))
               (inputs (commercial-font-inputs library))
               (original (getenv "MB_TYPE_DIR")))
          (dynamic-wind
              (lambda () (setenv "MB_TYPE_DIR" library))
              (lambda ()
                (for-each (lambda (entry)
                            (mkdir-p (dirname (cdr entry)))
                            (write-text (cdr entry) (car entry)))
                          inputs)
                (prepare-interface library public)
                (let* ((release (string-append root "/with-webfonts"))
                       (manifest (pack-site public source release))
                       (output (string-append root "/webfonts-extracted")))
                  (unpack-site (string-append release "/" (release-name manifest)
                                              ".tar.gz") manifest output)
                  (test-assert "Selected webfonts round-trip as original bytes"
                               (every (lambda (entry)
                                        (equal? (file-digest (cdr entry))
                                                (file-digest (string-append output "/"
                                                                            (car entry)))))
                                      inputs)))
                (write-text (string-append public "/" (caar inputs)) "modified")
                (test-assert "Reject modified commercial webfonts in an archive"
                             (string-contains
                              (failure-message
                               (lambda () (pack-site public source
                                                     (string-append root "/modified"))))
                              "Interface asset differs from its declared input"))
                (prepare-interface #f public)
                (test-assert "Removing private input removes fonts and declarations"
                             (and (not (any (lambda (name)
                                              (file-exists? (string-append public "/" name)))
                                            commercial-font-names))
                                  (not (string-contains
                                        (read-text (string-append public "/fonts.css"))
                                        "woff2")))))
              (lambda ()
                (if original (setenv "MB_TYPE_DIR" original)
                    (unsetenv "MB_TYPE_DIR")))))
        (delete-file (string-append public "/index.html"))
        (symlink "style.css" (string-append public "/index.html"))
        (test-assert "Reject symlink in publication output"
                     (string-contains
                      (failure-message
                       (lambda () (pack-site public source (string-append root "/links"))))
                      "link or special file"))
        ;; Use an unsafe entry with otherwise valid tar and gzip metadata.
        (run "tar" "--format=ustar" "-czf" (string-append root "/links.tar.gz")
             "-C" public "index.html")
        (let* ((bad (string-append root "/links.tar.gz"))
               (metadata (jset (jset manifest "sha256" (file-digest bad))
                               "size" (stat:size (stat bad)))))
          (test-assert "Reject archive links and preserve existing output"
                       (and (string-contains
                             (failure-message
                              (lambda () (unpack-site bad metadata
                                                      (string-append root "/unsafe"))))
                             "Unsafe site archive entry")
                            (not (file-exists? (string-append root "/unsafe")))
                            (file-exists? (string-append output "/index.html")))))))
    (lambda () (delete-tree root)))
(test-end "site-archive")
(exit (zero? (test-runner-fail-count runner)))
