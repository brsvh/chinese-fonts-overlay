(use-modules (chinese-fonts-overlay-site util)
             (chinese-fonts-overlay-site build)
             (chinese-fonts-overlay-site interface)
             (chinese-fonts-overlay-site previews)
             (srfi srfi-1)
             (srfi srfi-64))

;; Static publication must preserve Unicode labels in minimal build environments.
(setlocale LC_ALL "C")

(test-begin "publication")
(define runner (test-runner-current))
(define fixtures (getenv "FONT_SITE_FIXTURES"))
(define temporary (temporary-directory (or (getenv "TMPDIR") "/tmp")))
(define image-pixels
  (call-with-input-string
   (capture (getenv "FONT_SITE_IMAGE_FIXTURES") temporary) read))
(test-equal "Lossless WebP preserves straight RGBA from padded Cairo pixels"
  (car image-pixels) (cadr image-pixels))
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
    ("displayName" . ,(string-append "测试字体 " name ": @{A}, B"))
    ("attribute" . ,(string-append "testPackages." name))
    ("version" . "1")
    ("vendor" . "test")
    ("vendorName" . "测试字库")
    ("description" . "<script>unsafe</script> @README@ @LICENSE@ @REVISION@")
    ("longDescription" . "详细说明：@README@ @LICENSE@ @REVISION@")
    ("languages" . ,languages)
    ("styles" . #("sans"))
    ("embedding" . #t)
    ("licenseCost" . "free")
    ("licenses" . #((("id" . "CC0-1.0") ("name" . "CC0") ("free" . #t)
                     ("spdxId" . "CC0-1.0")
                     ("url" . "https://example.test/license"))))
    ("redistributable" . #f)
    ("homepages" . ,(cond
                     ((string=? name "english")
                      #("javascript:alert(1)"
                        "https://example.test/font?lang=en&view=family"
                        "https://example.test/font/source"))
                     ((string=? name "variable")
                      #("https://example.test/variable"))
                     (else #("javascript:alert(1)"))))
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
    ("vendors" ("test" . "Fixture（测试字库）"))
    ("licenseCostLabels" ("free" . "无许可费")
     ("gratisCommercialUse" . "商业免费许可")
     ("gratisPersonalUse" . "个人免费许可") ("paid" . "付费使用"))
    ("styleLabels" ("sans" . "无衬线体"))
    ("noticeLevelLabels" ("warning" . "警告"))))

(define manual-build (string-append temporary "/docs"))
(define manual (string-append manual-build "/manual"))
(define manual-reference (string-append temporary "/reference.json"))
(write-json manual-reference catalog)
(run "env" "-u" "MAKEFLAGS" "make" "-C" (getenv "FONT_SITE_DOCS") "check"
     (string-append "BUILD_DIR=" manual-build)
     (string-append "REFERENCE=" manual-reference)
     (string-append "SOURCE_REVISION=" revision))

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
  "Build a complete fixture site and capture its outcome."
  (let ((catalog-file (string-append temporary "/catalog.json"))
        (inputs-file (string-append temporary "/inputs.json")))
    (write-json catalog-file metadata)
    (write-json inputs-file sources)
    (command-result
     (lambda ()
       (catch #t
              (lambda ()
                (build-site catalog-file inputs-file
                            (string-append temporary "/cache") output commit
                            #:manual manual)
                0)
              (lambda (key . args)
                (print-exception (current-error-port) #f key args)
                1))))))

(define (published-files)
  "Return public relative paths and content digests in a stable order."
  (map (lambda (file)
         (cons (substring file (+ 1 (string-length output)))
               (file-digest file)))
       (sort (files-under output) string<?)))

(mkdir-p (string-append output "/assets/fonts"))
(write-text (string-append output "/assets/fonts/stale.ttf") "stale font")
(test-assert "Build complete static site"
  (let ((result (build-result catalog inputs)))
    (unless (zero? (car result))
      (display (cdr result) (current-error-port)))
    (zero? (car result))))

(define public (read-json (string-append output "/catalog.json")))
(define page (read-text (string-append output "/index.html")))

(define (published-package name)
  "Read the published catalog entry for fixture package NAME."
  (find (lambda (package) (equal? name (jref package "pname")))
        (jarray (jref public "packages"))))

(define (published-faces name)
  "Read the published faces for fixture package NAME."
  (jarray (jref (jref (published-package name) "preview") "faces")))

(define (published-samples name)
  "Read the first face's public language samples for fixture package NAME."
  (let ((face (car (published-faces name))))
    (jref (read-json (string-append output "/" (jref face "manifest")))
          "samples")))

(test-assert "Readable metadata is preserved and escaped; unsafe links are omitted"
  (and (string-contains page "&lt;script&gt;unsafe&lt;/script&gt;")
       (string-contains page "&lt;unsafe&gt;")
       (string-contains page "注意事项")
       (string-contains page ">（中国大陆）<")
       (string-contains page ">测试字库<")
       (string-contains page "详细说明：@README@ @LICENSE@ @REVISION@")
       (not (string-contains page "javascript:"))))

(test-assert "Package and site links use the source revision"
  (every (lambda (path)
           (string-contains page (string-append revision path)))
         '("/packages/test/english/package.nix" "/COPYING" "/site")))

(test-assert "Manual shares the site shell and preserves literal metadata"
  (let ((manual-page
         (read-text (string-append output "/manual/Vendor_002dtest.html"))))
    (and (string-contains page "href=\"./manual/index.html\"")
         (string-contains manual-page "aria-label=\"手册目录\"")
         (string-contains manual-page "class=\"site-footer\"")
         (string-contains manual-page "&lt;script&gt;unsafe&lt;/script&gt;")
         (not (string-contains manual-page "href=\"javascript:"))
         (file-exists? (string-append output "/manual/chinese-fonts-overlay.info")))))

(test-assert "Single and multiple upstream homepages are linked in source order"
  (let ((first (string-contains
                page "href=\"https://example.test/font?lang=en&amp;view=family\""))
        (second (string-contains
                 page "href=\"https://example.test/font/source\"")))
    (and first second (< first second)
         (string-contains page "href=\"https://example.test/variable\""))))

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

(test-equal "Catalog preserves reviewed display names and explicit embedding"
  '("测试字体 english: @{A}, B" "测试字体 variable: @{A}, B"
    #t #f "open" 300 "normal")
  (let ((package (published-package "english"))
        (face (car (published-faces "variable"))))
    (list (jref package "displayName")
          (jref (published-package "variable") "displayName")
          (jref package "embedding")
          (jref package "redistributable")
          (vector-ref (jref package "licenseCategories") 0)
          (jref face "weight") (jref face "style"))))

(define snapshot (published-files))
(test-assert "Static output includes only selected interface fonts and public assets"
  (and (every (lambda (name) (assoc name snapshot))
              '("index.html" "catalog.json" "bridge.js" "main.wasm"
                "reflect.js" "reflect.wasm" "wtf8.wasm" "style.css"
                "fonts.css" "presentation.js" "manual.js"
                "licenses.html" "tsanger-license.pdf" "favicon.svg" "cc0.svg"))
       (equal? (filter font-file? (map car snapshot))
               '("yuyang-medium.ttf" "yuyang-regular.ttf"))
       (equal? (filter (lambda (name) (string-suffix? ".woff2" name))
                       (map car snapshot))
               (sort (filter (lambda (name) (file-exists? (web-file name)))
                             commercial-font-names)
                     string<?))
       (not (string-contains (read-text (string-append output "/catalog.json"))
                             temporary))
       (let ((images (files-under (string-append output "/assets/images"))))
         (and (pair? images)
              (every (lambda (file)
                       (and (string-suffix? ".webp" file)
                            (validate-image file)))
                     images)))))

(let ((root (dirname (getenv "FONT_SITE_DATA")))
      (style (string-append output "/style.css")))
  (define (rebuild)
    "Run the normal incremental build against the existing fixture inputs."
    (system* (or (getenv "GUILE") "guile") "--no-auto-compile"
             "-L" (string-append root "/module")
             "-L" (string-append (getenv "FONT_SITE_DOCS") "/module")
             (string-append root "/scripts/build.scm")
             root temporary (string-append temporary "/cache")
             (string-append temporary "/catalog.json")
             (string-append temporary "/inputs.json") revision manual))
  (symlink (getenv "FONT_SITE_WEB") (string-append temporary "/web"))
  (test-assert "Incremental builds restore changed and missing output"
    (and (zero? (rebuild))
         (let ((image
                (car (files-under
                      (string-append temporary "/previews/assets/images")))))
           (delete-file style)
           (write-text
            (string-append output "/"
                           (jref (cdar (published-samples "english")) "url"))
            "damaged published image")
           (write-text image "damaged prepared preview")
           (and (zero? (rebuild))
                (equal? snapshot (published-files))
                (validate-image image))))))

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

(let* ((file (string-append manual "/reference.json"))
       (reference (read-json file)))
  (dynamic-wind
    (lambda ()
      (write-json file (jset reference "sourceRevision" (make-string 40 #\a))))
    (lambda ()
      (let ((result (build-result catalog inputs)))
        (test-assert "Reject a manual from a different source revision"
          (and (= 1 (car result))
               (string-contains (cdr result)
                                "Manual and website source revisions differ")))))
    (lambda () (write-json file reference))))

(let ((page (string-append manual "/html/Installation.html"))
      (saved (string-append temporary "/saved-manual-page")))
  (dynamic-wind
    (lambda () (rename-file page saved))
    (lambda ()
      (let ((result (build-result catalog inputs)))
        (test-assert "Reject a manual with a missing linked page"
          (and (= 1 (car result))
               (string-contains (cdr result) "Broken manual link")))))
    (lambda () (rename-file saved page))))

(define incomplete-web (string-append temporary "/incomplete-web"))
(mkdir-p incomplete-web)
(for-each
 (lambda (file)
   (unless (equal? (basename file) "bridge.js")
     (copy-file file (string-append incomplete-web "/" (basename file)))))
 (files-under (getenv "FONT_SITE_WEB")))
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

(define missing-image (string-append temporary "/missing.webp"))
(render-jobs
 (list (list (string-append fixtures "/static.ttf") "0" "-" "en" "AZ"
             missing-image)))
(test-assert "Renderer rejects missing glyphs without system fallback"
  (and (not (file-exists? missing-image))
       (file-exists? (string-append missing-image ".unsupported"))))

(define invalid-job (string-append temporary "/invalid.tsv"))
(write-text invalid-job
            (string-append fixtures "/static.ttf\tnot-an-index\t-\ten\tA\t"
                           temporary "/invalid.webp\n"))
(define unwritable-job (string-append temporary "/unwritable.tsv"))
(write-text unwritable-job
            (string-append fixtures "/static.ttf\t0\t-\ten\tA\t"
                           temporary "/absent/sample.webp\n"))
(for-each
 (lambda (case)
   (let ((result (command-result
                  (lambda ()
                    (system* (getenv "FONT_SITE_RENDERER") (car case))))))
     (test-assert (cdr case)
       (and (not (zero? (car result)))
            (string-contains (cdr result) (cdr case))))))
 `((,invalid-job . "Invalid font face index")
   (,unwritable-job . "Cannot write")
   (,temporary . "Cannot read sample manifest")))

(for-each
 (lambda (case)
   (let ((result
          (command-result
           (lambda ()
             (system* (getenv "FONT_SITE_INSPECTOR") "image-info"
                      (string-append temporary "/" (car case)))))))
     (test-assert (cdr case)
       (and (not (zero? (car result)))
            (string-contains (cdr result) (cdr case))))))
 '(("blank.webp" . "Expected nonblank WebP")
   ("opaque.webp" . "Expected transparent WebP")
   ("edge.webp" . "Expected transparent WebP borders")
   ("lossy.webp" . "Expected static lossless WebP")
   ("truncated.webp" . "Invalid WebP pixels")))

(delete-tree temporary)
(test-end "publication")
(exit (zero? (test-runner-fail-count runner)))
