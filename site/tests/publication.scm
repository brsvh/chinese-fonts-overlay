(use-modules (chinese-fonts-overlay-site util)
             (chinese-fonts-overlay-site command)
             (chinese-fonts-overlay-site previews)
             (srfi srfi-1)
             (srfi srfi-64))

(test-begin "publication")
(define runner (test-runner-current))
(define fixtures (getenv "FONT_SITE_FIXTURES"))
(define temporary (temporary-directory (or (getenv "TMPDIR") "/tmp")))
(define output (string-append temporary "/public"))
(define revision "0123456789012345678901234567890123456789")

(define (fixture-package name font languages)
  "Create a local fixture package and return its public catalog metadata."
  (let ((directory (string-append temporary "/" name "/share/fonts")))
    (mkdir-p directory)
    (copy-file (string-append fixtures "/" font)
               (string-append directory "/" font)))
  `(("id" . ,(string-append "test." name))
    ("pname" . ,name)
    ("attribute" . ,(string-append "testPackages." name))
    ("version" . "1")
    ("vendor" . "test")
    ("vendorName" . "测试字库")
    ("description" . "<script>unsafe</script>")
    ("longDescription" . "详细说明")
    ("languages" . ,languages)
    ("styles" . #("sans"))
    ("licenseCost" . "none")
    ("licenses" . #((("id" . "CC0-1.0") ("name" . "CC0")
                      ("spdxId" . "CC0-1.0")
                      ("url" . "https://example.test/license"))))
    ("redistributable" . #f)
    ("homepages" . #("javascript:alert(1)"))
    ("source" ("path" . ,(string-append "packages/test/" name "/package.nix")))
    ("notices" . #((("level" . "warning") ("text" . "<unsafe>\n注意事项"))))))

(define packages
  (list (fixture-package "english" "english.ttf" #("en" "zh-cn"))
        (fixture-package "missing" "english.ttf" #("ja"))
        (fixture-package "symbols" "symbols.ttf" #())
        (fixture-package "variable" "variable.ttf" #("en"))
        (fixture-package "collection" "collection.ttc" #("en"))))

(define catalog
  `(("packages" . ,(list->vector packages))
    ("vendors" ("test" . "测试字库"))
    ("licenseCostLabels" ("none" . "无") ("commercialFree" . "商业免费使用")
                         ("personalFree" . "个人免费使用") ("paid" . "付费使用"))
    ("styleLabels" ("sans" . "无衬线体"))
    ("noticeLevelLabels" ("warning" . "警告"))))

(define inputs
  (map (lambda (package)
         (cons (jref package "id")
               `(("renderPath" . ,(string-append temporary "/"
                                                 (jref package "pname"))))))
       packages))

(define (command-result thunk)
  "Run THUNK and return its exit status paired with captured diagnostics."
  (let* ((file (string-append temporary "/diagnostic"))
         (status (call-with-output-file
                     file
                   (lambda (port) (with-error-to-port port thunk)))))
    (cons status (read-text file))))

(define* (build-result metadata sources #:optional (commit revision))
  "Build a complete fixture site through the CLI and capture its outcome."
  (let ((catalog-file (string-append temporary "/catalog.json"))
        (inputs-file (string-append temporary "/inputs.json")))
    (write-json catalog-file metadata)
    (write-json inputs-file sources)
    (command-result
     (lambda ()
       (main (list "--build" "--catalog" catalog-file "--previews" inputs-file
                   "--source-root" temporary "--revision" commit
                   "--cache" (string-append temporary "/cache")
                   "--output" output))))))

(define (published-files)
  "Return public relative paths and content digests in a stable order."
  (map (lambda (file)
         (cons (substring file (+ 1 (string-length output)))
               (file-digest file)))
       (sort (files-under output) string<?)))

(mkdir-p (string-append output "/assets/fonts"))
(write-text (string-append output "/assets/fonts/stale.ttf") "stale font")
(test-equal "Build complete static site" 0 (car (build-result catalog inputs)))

(define public (read-json (string-append output "/catalog.json")))
(define page (read-text (string-append output "/index.html")))

(define (published-faces name)
  "Read the published faces for fixture package NAME."
  (let ((package
         (find (lambda (package) (equal? name (jref package "pname")))
               (jarray (jref public "packages")))))
    (jarray (jref (jref package "preview") "faces"))))

(define (published-samples name)
  "Read the first face's public language samples for fixture package NAME."
  (let ((face (car (published-faces name))))
    (jref (read-json (string-append output "/" (jref face "manifest")))
          "samples")))

(test-assert "Readable metadata is escaped and unsafe links are omitted"
  (and (string-contains page "&lt;script&gt;unsafe&lt;/script&gt;")
       (string-contains page "&lt;unsafe&gt;")
       (string-contains page "注意事项")
       (not (string-contains page "javascript:"))))

(test-assert "Package source and redistribution metadata are published"
  (and (equal? (map (lambda (package) (jref package "pname"))
                    (jarray (jref public "packages")))
               '("english" "missing" "symbols" "variable" "collection"))
       (string-contains page "再分发")
       (string-contains
        page (string-append "/blob/" revision
                             "/packages/test/english/package.nix"))))

(test-equal "Previews respect covered, missing and unknown languages"
  '(("en") () ("unknown"))
  (map (lambda (name) (map car (published-samples name)))
       '("english" "missing" "symbols")))

(test-equal "Every named weight and collection member is published"
  '(("Variable Light" "Variable Regular" "Variable Bold")
    ("First Regular" "Second Regular"))
  (map (lambda (name)
         (map (lambda (face) (jref face "name")) (published-faces name)))
       '("variable" "collection")))

(define snapshot (published-files))
(test-assert "Static output contains assets and transparent previews, not fonts"
  (and (every (lambda (name) (assoc name snapshot))
              '("index.html" "catalog.json" "bridge.js" "main.wasm"
                "reflect.js" "reflect.wasm" "wtf8.wasm"))
       (not (any font-file? (map car snapshot)))
       (not (string-contains (read-text (string-append output "/catalog.json"))
                             temporary))
       (every (lambda (file) (validate-image file))
              (filter (lambda (file) (string-suffix? ".png" file))
                      (files-under output)))))

(write-text
 (string-append output "/" (jref (cdar (published-samples "english")) "url"))
 "damaged published image")
(test-assert "Cached rebuild restores damaged public output"
  (and (zero? (car (build-result catalog inputs)))
       (equal? snapshot (published-files))))

(for-each
 (lambda (case)
   (let ((result (build-result (car case) (cadr case) (caddr case))))
     (test-assert (cadddr case)
       (and (= 1 (car result)) (string-contains (cdr result) (cadddr case))))))
 (list
  (list catalog (cdr inputs) revision
        "Preview selection must match the complete catalog")
  (list catalog
        (jset inputs "test.english"
              '(("path" . "font.ttf") ("renderPath" . #f)))
        revision "Font must only have a local renderer path")
  (list (jset catalog "packages"
              (list->vector (cons (jset (car packages) "languages" #("xx"))
                                  (cdr packages))))
        inputs revision "Missing language samples")
  (list catalog inputs "main" "Expected a full source commit SHA")))

(define incomplete-web (string-append temporary "/incomplete-web"))
(mkdir-p incomplete-web)
(copy-file (web-file "index.html") (string-append incomplete-web "/index.html"))
(let ((web (getenv "FONT_SITE_WEB")))
  (dynamic-wind
    (lambda () (setenv "FONT_SITE_WEB" incomplete-web))
    (lambda ()
      (let ((result (build-result catalog inputs)))
        (test-assert "Missing browser assets abort publication"
          (and (= 1 (car result))
               (string-contains (cdr result) "copy-file")))))
    (lambda () (setenv "FONT_SITE_WEB" web))))

(let ((renderer (getenv "FONT_SITE_RENDERER"))
      (empty-renderer (search-path (string-split (getenv "PATH") #\:) "true")))
  (dynamic-wind
    (lambda () (setenv "FONT_SITE_RENDERER" empty-renderer))
    (lambda ()
      (let ((result (build-result catalog inputs)))
        (test-assert "Changed renderer invalidates cached images"
          (and (= 1 (car result))
               (string-contains (cdr result) "Renderer produced no result")))))
    (lambda () (setenv "FONT_SITE_RENDERER" renderer))))

(let ((inspector (getenv "FONT_SITE_INSPECTOR"))
      (failed-inspector (search-path (string-split (getenv "PATH") #\:) "false")))
  (dynamic-wind
    (lambda () (setenv "FONT_SITE_INSPECTOR" failed-inspector))
    (lambda ()
      (let ((result (build-result catalog inputs)))
        (test-assert "Changed inspector cannot reuse stale face metadata"
          (and (= 1 (car result))
               (string-contains (cdr result) "Command failed")
               (string-contains (cdr result) failed-inspector)))))
    (lambda () (setenv "FONT_SITE_INSPECTOR" inspector))))

(test-equal "Failed builds preserve the entire previous site"
  snapshot (published-files))

(define missing-image (string-append temporary "/missing.png"))
(render-jobs
 (list (list (string-append fixtures "/static.ttf") "0" "-" "en" "AZ"
             missing-image)))
(test-assert "Renderer rejects missing glyphs without system fallback"
  (and (not (file-exists? missing-image))
       (file-exists? (string-append missing-image ".unsupported"))))

(define invalid-job (string-append temporary "/invalid.tsv"))
(write-text invalid-job
            (string-append fixtures "/static.ttf\tnot-an-index\t-\ten\tA\t"
                           temporary "/invalid.png\n"))
(for-each
 (lambda (case)
   (let ((result (command-result
                  (lambda ()
                    (system* (getenv "FONT_SITE_RENDERER") (car case))))))
     (test-assert (cdr case)
       (and (not (zero? (car result)))
            (string-contains (cdr result) (cdr case))))))
 `((,invalid-job . "Invalid font face index")
   (,temporary . "Cannot read sample manifest")))

(for-each
 (lambda (case)
   (let ((result
          (command-result
           (lambda ()
             (system* (getenv "FONT_SITE_INSPECTOR") "image-info"
                      (string-append fixtures "/" (car case)))))))
     (test-assert (cdr case)
       (and (not (zero? (car result)))
            (string-contains (cdr result) (cdr case))))))
 '(("blank.png" . "Expected nonblank PNG")
   ("opaque.png" . "Expected transparent PNG")))

(delete-tree temporary)
(test-end "publication")
(exit (zero? (test-runner-fail-count runner)))
