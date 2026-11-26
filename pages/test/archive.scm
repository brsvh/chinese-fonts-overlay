(use-modules (chinese-fonts-overlay pages archive)
             (chinese-fonts-overlay pages presentation assets)
             (chinese-fonts-overlay pages presentation fonts)
             (chinese-fonts-overlay pages util)
             (srfi srfi-1)
             (srfi srfi-64))

(define (failure-message thunk)
  "Return the diagnostic from THUNK's expected content-validation failure."
  (catch 'misc-error
    (lambda () (thunk) "")
    (lambda (key procedure message arguments . rest)
      (apply format #f message arguments))))

(define ui-assets
  '(("yuyang-regular.ttf" . "UI_FONT_REGULAR")
    ("yuyang-medium.ttf" . "UI_FONT_MEDIUM")
    ("tsanger-license.pdf" . "UI_FONT_LICENSE")))

(define (tree-digests directory)
  "Pair each relative path beneath DIRECTORY with its SHA256 digest."
  (map (lambda (file)
         (cons (substring file (+ 1 (string-length directory)))
               (file-digest file)))
       (files-under directory)))

(define (restore-env! entries)
  "Restore each (NAME . VALUE-OR-FALSE) environment binding in ENTRIES."
  (for-each (lambda (entry)
              (if (cdr entry)
                  (setenv (car entry) (cdr entry))
                  (unsetenv (car entry))))
            entries))

(test-begin "site-archive")
(define runner (test-runner-current))
(define root (temporary-directory (nonempty-env "TMPDIR" "/tmp")))
(define source (make-string 40 #\a))
(define public (string-append root "/public"))
(define ui-inputs (string-append root "/ui-inputs"))
(define original-ui-env
  (map (lambda (asset) (cons (cdr asset) (getenv (cdr asset)))) ui-assets))

(dynamic-wind
  (lambda () #t)
  (lambda ()
    (mkdir public)
    (mkdir (string-append public "/manual"))
    (mkdir ui-inputs)
    (for-each
     (lambda (name) (write-text (string-append public "/" name) name))
     (append (browser-assets)
             '("index.html" "catalog.json" "previews.json"
               "manual/index.html" "manual/chinese-fonts-overlay.info"
               "manual/Installation.html")))
    (write-json (string-append public "/catalog.json")
                `(("sourceRevision" . ,source)))
    (chmod (string-append public "/index.html") #o755)
    (mkdir-p (string-append public "/assets/previews"))
    (write-json (string-append public "/assets/previews/"
                               (make-string 64 #\b) ".json")
                '(("samples" . #())))
    (for-each (lambda (asset)
                (let ((declared (string-append ui-inputs "/" (car asset))))
                  (write-text declared (car asset))
                  (copy-file declared (string-append public "/" (car asset)))
                  (setenv (cdr asset) declared)))
              ui-assets)
    (let* ((release (string-append root "/release"))
           (manifest (pack-site public source release))
           (archive (string-append release "/" (release-name manifest)
                                   ".tar.gz"))
           (output (string-append root "/extracted")))
      (unpack-site archive manifest output)
      (test-assert "Round-trip public files with normalized permissions"
        (and (equal? (tree-digests public)
                     (tree-digests output))
             (= #o644
                (stat:perms (stat (string-append output "/index.html"))))))
      (test-assert "Reject corrupt archive before extraction"
        (and (string-contains
              (failure-message
               (lambda ()
                 (unpack-site archive
                              (jset manifest "sha256" (make-string 64 #\0))
                              (string-append root "/bad"))))
              "digest or size mismatch")
             (not (file-exists? (string-append root "/bad")))))
      (let ((script (string-append public "/navigation.js"))
            (saved (string-append root "/navigation.js")))
        (dynamic-wind
          (lambda () (rename-file script saved))
          (lambda ()
            (test-assert "Reject missing browser navigation"
              (string-contains
               (failure-message
                (lambda ()
                  (pack-site public source
                             (string-append root "/missing-nav"))))
               "Missing required public files")))
          (lambda () (rename-file saved script))))
      (let ((template (string-append public "/notices-dialog.html")))
        (dynamic-wind
          (lambda () (write-text template "template"))
          (lambda ()
            (test-assert "Reject unpublished page templates"
              (string-contains
               (failure-message
                (lambda ()
                  (pack-site public source
                             (string-append root "/unpublished"))))
               "Unexpected public file")))
          (lambda () (delete-file template))))
      (let* ((name (caar ui-assets))
             (declared (string-append ui-inputs "/" name))
             (published (string-append public "/" name)))
        (dynamic-wind
          (lambda () (write-text published "tampered"))
          (lambda ()
            (test-assert "Reject modified interface assets in an archive"
              (string-contains
               (failure-message
                (lambda ()
                  (pack-site public source (string-append root "/bad-ui"))))
               "Interface asset differs from its declared input")))
          (lambda () (copy-file declared published))))
      ;; Byte fixtures exercise packaging without requiring purchased fonts.
      (let* ((library (string-append root "/library"))
             (inputs (commercial-font-inputs library))
             (original (getenv "WEBFONTS_DIR")))
        (dynamic-wind
          (lambda () (setenv "WEBFONTS_DIR" library))
          (lambda ()
            (for-each (lambda (entry)
                        (mkdir-p (dirname (cdr entry)))
                        (write-text (cdr entry) (car entry)))
                      inputs)
            (prepare-interface library public)
            (let* ((release (string-append root "/with-webfonts"))
                   (manifest (pack-site public source release))
                   (output (string-append root "/webfonts-extracted")))
              (unpack-site
               (string-append release "/" (release-name manifest) ".tar.gz")
               manifest output)
              (let ((css (read-text (string-append output "/fonts.css"))))
                (test-assert "Selected webfonts round-trip as original bytes"
                  (and (every
                        (lambda (entry)
                          (equal?
                           (file-digest (cdr entry))
                           (file-digest
                            (string-append output "/" (car entry)))))
                        inputs)
                       (string-contains css "woff2")
                       (string-contains css "--site-code-font: Triplicate")))))
            (write-text (string-append public "/" (caar inputs)) "modified")
            (test-assert "Reject modified commercial webfonts in an archive"
              (string-contains
               (failure-message
                (lambda ()
                  (pack-site public source (string-append root "/modified"))))
               "Interface asset differs from its declared input"))
            (prepare-interface #f public)
            (let ((css (read-text (string-append public "/fonts.css"))))
              (test-assert
                "Removing private input removes fonts and declarations"
                (and (not (any (lambda (name)
                                 (file-exists? (string-append public "/" name)))
                               (commercial-font-names)))
                     (not (string-contains css "woff2"))
                     (not (string-contains css "--site-code-font"))
                     (string-contains css "yuyang-regular.ttf")))))
          (lambda () (restore-env! (list (cons "WEBFONTS_DIR" original))))))
      (delete-file (string-append public "/index.html"))
      (symlink "style.css" (string-append public "/index.html"))
      (test-assert "Reject symlink in publication output"
        (string-contains
         (failure-message
          (lambda () (pack-site public source (string-append root "/links"))))
         "link or special file"))
      ;; Write a valid file before the unsafe entry to test partial cleanup.
      (run "tar" "--format=ustar" "--mtime=@0" "--owner=0" "--group=0"
           "--numeric-owner" "--mode=0644" "--force-local" "-czf"
           (string-append root "/links.tar.gz")
           "-C" public "style.css" "index.html")
      (let* ((bad (string-append root "/links.tar.gz"))
             (metadata (jset (jset manifest "sha256" (file-digest bad))
                             "size" (stat:size (stat bad)))))
        (test-assert "Reject archive links without leaving partial output"
          (and (string-contains
                (failure-message
                 (lambda ()
                   (unpack-site bad metadata (string-append root "/unsafe"))))
                "Unsafe site archive entry")
               (not (file-exists? (string-append root "/unsafe"))))))))
  (lambda ()
    (restore-env! original-ui-env)
    (delete-tree root)))

(test-end "site-archive")
(exit (and (zero? (test-runner-fail-count runner))
           (zero? (test-runner-xpass-count runner))))
