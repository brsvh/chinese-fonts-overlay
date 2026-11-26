(use-modules (chinese-fonts-overlay pages util)
             (chinese-fonts-overlay pages build)
             (chinese-fonts-overlay pages presentation assets)
             (chinese-fonts-overlay pages presentation fonts)
             (chinese-fonts-overlay pages presentation layout)
             (chinese-fonts-overlay pages preview images)
             (chinese-fonts-overlay pages preview inspect)
             (srfi srfi-1)
             (srfi srfi-64))

;; Static publication must preserve Unicode labels in minimal environments.
(setlocale LC_ALL "C")

(test-begin "publication")
(define runner (test-runner-current))
(define fixtures (getenv "FONT_PAGES_FIXTURES"))
(define source-root (getenv "FONT_PAGES_SOURCE"))
(define temporary (temporary-directory (nonempty-env "TMPDIR" "/tmp")))

(define (with-env name value thunk)
  "Run THUNK with NAME set to VALUE, restoring its prior environment state."
  (let ((previous (getenv name)))
    (dynamic-wind
      (lambda () (setenv name value))
      thunk
      (lambda ()
        (if previous
            (setenv name previous)
            (unsetenv name))))))

(define (command-result thunk)
  "Run THUNK and return its exit status paired with captured diagnostics."
  (let* ((file (string-append temporary "/diagnostic"))
         (status (call-with-output-file
                     file
                   (lambda (port)
                     (set-port-encoding! port "UTF-8")
                     (with-error-to-port port thunk)))))
    (cons status (read-text file))))

(dynamic-wind
  (lambda () #t)
  (lambda ()
    (let* ((source (string-append temporary "/project/pages"))
           (modules (string-append source "/module"))
           (handwritten (in-vicinity modules "pages/manual/reference.scm"))
           (alias (string-append temporary "/linked-modules"))
           (cli (string-append source-root "/build-aux/directories.scm")))
      (define (rejected? args)
        (let ((result
               (command-result
                (lambda ()
                  (apply system* (nonempty-env "GUILE" "guile")
                         "--no-auto-compile" "-L"
                         (string-append source-root "/module")
                         cli args)))))
          (and (eqv? 1 (status:exit-val (car result)))
               (string-contains (cdr result)
                                "Output directory overlaps the source tree"))))
      (mkdir-p (dirname handwritten))
      (write-text handwritten "source")
      (symlink modules alias)
      (test-assert
        "Building and cleaning reject source directories through symlinks"
        (and (every rejected?
                    (list (list "clean-build" source
                                (in-vicinity modules "pages"))
                          (list "clean-cache" source alias)
                          (list "check" source (string-append alias "/new"))))
             (equal? (read-text handwritten) "source"))))

    (let* ((directory (string-append temporary "/previous"))
           (file (string-append directory "/page")))
      (mkdir directory)
      (write-text file "previous")
      (test-assert "Failed installation restores the previous directory"
        (and (catch 'system-error
               (lambda () (replace-directory! directory rmdir) #f)
               (lambda args #t))
             (equal? (read-text file) "previous"))))

    (let ((image-pixels
           (call-with-input-string
            (capture (getenv "FONT_PAGES_IMAGE_FIXTURES") temporary) read)))
      (test-equal
        "Lossless WebP preserves straight RGBA from padded Cairo pixels"
        (car image-pixels) (cadr image-pixels)))

    (let* ((output (string-append temporary "/public"))
           (revision "0123456789012345678901234567890123456789")
           (fixture-package
            (lambda (name font languages)
              (let ((directory
                     (string-append temporary "/" name "/share/fonts")))
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
                ("description" . "<script>unsafe</script>")
                ("longDescription" . "详细说明，\n支持多行中文")
                ("languages" . ,languages)
                ("styles" . #("sans"))
                ("embedding" . #t)
                ("licenseCost" . "free")
                ("licenses"
                 . #((("id" . "CC0-1.0") ("name" . "CC0") ("free" . #t)
                      ("spdxId" . "CC0-1.0")
                      ("url" . "https://example.test/license"))))
                ("redistributable" . #f)
                ("homepages"
                 . ,(cond
                     ((string=? name "english")
                      #("javascript:alert(1)"
                        "https://example.test/font?lang=en&view=family"
                        "https://example.test/font/source"))
                     ((string=? name "variable")
                      #("https://example.test/variable"))
                     (else #("javascript:alert(1)"))))
                ("source"
                 ("path" . ,(string-append "packages/test/"
                                           name "/package.nix")))
                ("notices"
                 . #((("level" . "warning") ("text" . "<unsafe>\n正文说明")))))))
           (packages
            (list (fixture-package "english" "english.ttf" #("en" "zh-cn"))
                  (fixture-package "missing" "english.ttf" #("ja"))
                  (fixture-package "symbols" "symbols.ttf" #())
                  (fixture-package "variable" "variable.ttf" #("en"))
                  (fixture-package "collection" "collection.ttc" #("en"))))
           (catalog
            `(("packages" . ,(list->vector packages))
              ("vendors" ("test" . "Fixture（测试字库）"))
              ("licenseCostLabels" ("free" . "无许可费")
               ("gratisCommercialUse" . "商业免费许可")
               ("gratisPersonalUse" . "个人免费许可") ("paid" . "付费使用"))
              ("styleLabels" ("sans" . "无衬线体"))
              ("noticeLevelLabels" ("warning" . "警告"))))
           (manual-build (string-append temporary "/docs"))
           (manual (string-append manual-build "/manual"))
           (manual-reference (string-append temporary "/reference.json"))
           (inputs
            (map (lambda (package)
                   (cons (jref package "id")
                         `(("renderPath"
                            . ,(string-append temporary "/"
                                              (jref package "pname"))))))
                 packages)))
      (define* (build-result metadata sources #:optional (commit revision))
        (let ((catalog-file (string-append temporary "/catalog.json"))
              (inputs-file (string-append temporary "/inputs.json")))
          (write-json catalog-file metadata)
          (write-json inputs-file sources)
          (command-result
           (lambda ()
             (catch #t
               (lambda ()
                 (build-site source-root temporary
                             (string-append temporary "/cache")
                             catalog-file inputs-file commit manual)
                 0)
               (lambda (key . args)
                 (print-exception (current-error-port) #f key args)
                 1))))))
      (define (published-files)
        (map (lambda (file)
               (cons (substring file (+ 1 (string-length output)))
                     (file-digest file)))
             (sort (files-under output) string<?)))
      (write-json manual-reference catalog)
      (run "env" "-u" "MAKEFLAGS" "-u" "MANUAL" "make" "-C" source-root
           "check-manual"
           (string-append "BUILD_DIR=" manual-build)
           (string-append "REFERENCE=" manual-reference)
           (string-append "SOURCE_REVISION=" revision))
      (mkdir-p (string-append output "/assets/fonts"))
      (write-text (string-append output "/assets/fonts/stale.ttf") "stale font")
      (test-assert "Build complete static site"
        (let ((result (build-result catalog inputs)))
          (unless (zero? (car result))
            (display (cdr result) (current-error-port)))
          (zero? (car result))))
      (let* ((public (read-json (string-append output "/catalog.json")))
             (page (read-text (string-append output "/index.html")))
             (published-package
              (lambda (name)
                (find (lambda (package) (equal? name (jref package "pname")))
                      (jarray (jref public "packages")))))
             (published-faces
              (lambda (name)
                (jarray (jref (jref (published-package name) "preview")
                              "faces"))))
             (published-samples
              (lambda (name)
                (let ((face (car (published-faces name))))
                  (jref (read-json
                         (string-append output "/" (jref face "manifest")))
                        "samples"))))
             (snapshot (published-files)))
        (test-assert
          "Readable metadata is preserved and escaped; unsafe links are omitted"
          (and (string-contains page "&lt;script&gt;unsafe&lt;/script&gt;")
               (string-contains page "&lt;unsafe&gt;\n正文说明")
               (string-contains page "详细说明")
               (not (string-contains page "javascript:"))))
        (test-assert "Package and site links use the source revision"
          (every (lambda (fragment) (string-contains page fragment))
                 (list (string-append "/tree/" revision)
                       (string-append revision
                                      "/packages/test/english/package.nix")
                       (string-append revision "/COPYING"))))
        (test-assert
          "Manual shares the site shell and preserves literal metadata"
          (let ((manual-page
                 (read-text
                  (string-append output "/manual/Vendor_002dtest.html"))))
            (and (string-contains page "href=\"./manual/index.html\"")
                 (string-contains manual-page "aria-label=\"手册目录\"")
                 (string-contains manual-page (string-append "/tree/" revision))
                 (string-contains manual-page
                                  "&lt;script&gt;unsafe&lt;/script&gt;")
                 (not (string-contains manual-page "href=\"javascript:"))
                 (file-exists?
                  (string-append output
                                 "/manual/chinese-fonts-overlay.info")))))
        (test-assert
          "Manual HTML collapses CJK line breaks without altering code or Latin spacing"
          (let ((manual-index
                 (read-text (string-append output "/manual/index.html")))
                (manual-vendor
                 (read-text
                  (string-append output "/manual/Vendor_002dtest.html")))
                (manual-installation
                 (read-text
                  (string-append output "/manual/Installation.html")))
                (manual-attributes
                 (read-text
                  (string-append output "/manual/Package_002dAttributes.html")))
                (manual-nixos
                 (read-text (string-append output "/manual/NixOS.html"))))
            (and (string-contains manual-index "由于同步收录发行方")
                 (not (string-contains manual-index "由于同步收录\n发行方"))
                 (string-contains manual-vendor "详细说明，支持多行中文")
                 (string-contains manual-installation "启用\noverlay")
                 (string-contains manual-attributes "而\n마루 부리")
                 (string-contains manual-nixos
                                  "chinese-fonts-overlay = {\n  url ="))))
        (test-assert
          "Both entry points include the MB Type and Tsanger font licenses"
          (let ((chapter
                 (read-text
                  (string-append output "/manual/Installation.html"))))
            (and (every
                  (lambda (html)
                    (and (string-contains html "commandfor=\"site-notices\"")
                         (string-contains html "<dialog")
                         (string-contains
                          html "href=\"https://mbtype.com/license/\"")
                         (string-contains
                          html
                          "https://protesilaos.com/emacs/modus-themes-colors")))
                  (list page chapter))
                 (string-contains page "href=\"./tsanger-license.pdf\"")
                 (string-contains chapter "href=\"../tsanger-license.pdf\""))))
        (test-assert
          "Single and multiple upstream homepages are linked in source order"
          (let ((first
                 (string-contains
                  page
                  "href=\"https://example.test/font?lang=en&amp;view=family\""))
                (second
                 (string-contains
                  page "href=\"https://example.test/font/source\"")))
            (and first second (< first second)
                 (string-contains
                  page "href=\"https://example.test/variable\""))))
        (test-equal "Previews respect covered, missing and unknown languages"
          '(("en") () ("unknown"))
          (map (lambda (name) (map car (published-samples name)))
               '("english" "missing" "symbols")))
        (test-equal "Every named weight and collection member is published"
          '(("Variable Light" "Variable Regular" "Variable Bold")
            ("First Regular" "Second Regular"))
          (map (lambda (name)
                 (map (lambda (face) (jref face "name"))
                      (published-faces name)))
               '("variable" "collection")))
        (test-equal
          "Catalog preserves reviewed display names and explicit embedding"
          '("测试字体 english: @{A}, B" #t #f "open" 300 "normal")
          (let ((package (published-package "english"))
                (face (car (published-faces "variable"))))
            (list (jref package "displayName")
                  (jref package "embedding")
                  (jref package "redistributable")
                  (vector-ref (jref package "licenseCategories") 0)
                  (jref face "weight")
                  (jref face "style"))))
        (test-assert
          "Static output includes only selected interface fonts and assets"
          (and (every (lambda (name) (assoc name snapshot))
                      (append (browser-assets)
                              '("index.html" "catalog.json" "previews.json")))
               (not (assoc "notices-dialog.html" snapshot))
               (not (assoc "startup-head.html" snapshot))
               (equal? (filter font-file? (map car snapshot))
                       '("yuyang-medium.ttf" "yuyang-regular.ttf"))
               (equal? (filter (lambda (name) (string-suffix? ".woff2" name))
                               (map car snapshot))
                       (sort (filter (lambda (name)
                                       (file-exists? (web-file name)))
                                     (commercial-font-names))
                             string<?))
               (not (string-contains
                     (read-text (string-append output "/catalog.json"))
                     temporary))
               (let ((images
                      (files-under (string-append output "/assets/images"))))
                 (and (pair? images)
                      (every (lambda (file)
                               (and (string-suffix? ".webp" file)
                                    (validate-image file)))
                             images)))))
        (let ((style (string-append output "/style.css")))
          (define (rebuild)
            (system* (nonempty-env "GUILE" "guile") "--no-auto-compile"
                     "-L" (string-append source-root "/module")
                     (string-append source-root "/build-aux/build.scm")
                     source-root temporary (string-append temporary "/cache")
                     (string-append temporary "/catalog.json")
                     (string-append temporary "/inputs.json") revision manual))
          (test-assert "Incremental builds restore changed and missing output"
            (and (zero? (rebuild))
                 (let ((image
                        (car (files-under
                              (string-append temporary
                                             "/previews/assets/images")))))
                   (delete-file style)
                   (write-text
                    (string-append
                     output "/"
                     (jref (cdar (published-samples "english")) "url"))
                    "damaged published image")
                   (write-text image "damaged prepared preview")
                   (write-text (in-vicinity temporary "previews/previews.json")
                               "damaged preview dimensions")
                   (and (zero? (rebuild))
                        (equal? snapshot (published-files))
                        (validate-image image))))))
        (for-each
         (lambda (case)
           (let ((result (build-result (car case) (cadr case) (caddr case))))
             (test-assert (cadddr case)
               (and (= 1 (car result))
                    (string-contains (cdr result) (cadddr case))))))
         (list
          (list catalog (cdr inputs) revision
                "Preview selection must match the complete catalog")
          (list catalog
                (jset inputs "test.english"
                      '(("path" . "font.ttf") ("renderPath" . #f)))
                revision "Font must only have a local renderer path")
          (list (jset catalog "packages"
                      (list->vector
                       (cons (jset (car packages) "languages" #("xx"))
                             (cdr packages))))
                inputs revision "Missing language samples")
          (list catalog inputs "main" "Expected a full source commit SHA")))
        (let* ((file (string-append manual "/reference.json"))
               (reference (read-json file)))
          (dynamic-wind
            (lambda ()
              (write-json file
                          (jset reference "sourceRevision"
                                (make-string 40 #\a))))
            (lambda ()
              (let ((result (build-result catalog inputs)))
                (test-assert "Reject a manual from a different source revision"
                  (and (= 1 (car result))
                       (string-contains
                        (cdr result)
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
        (let ((incomplete-web (string-append temporary "/incomplete-web")))
          (mkdir-p incomplete-web)
          (for-each
           (lambda (file)
             (unless (equal? (basename file) "bridge.js")
               (copy-file file
                          (string-append incomplete-web "/" (basename file)))))
           (files-under (getenv "FONT_PAGES_WEB")))
          (with-env
           "FONT_PAGES_WEB" incomplete-web
           (lambda ()
             (let ((result (build-result catalog inputs)))
               (test-assert "Missing browser assets abort publication"
                 (and (= 1 (car result))
                      (string-contains (cdr result)
                                       "Missing required browser asset")))))))
        (let ((empty-renderer
               (search-path (string-split (getenv "PATH") #\:) "true")))
          (with-env
           "FONT_PAGES_RENDERER" empty-renderer
           (lambda ()
             (let ((result (build-result catalog inputs)))
               (test-assert "Changed renderer invalidates cached images"
                 (and (= 1 (car result))
                      (string-contains (cdr result)
                                       "Renderer produced no result")))))))
        (let ((failed-inspector
               (search-path (string-split (getenv "PATH") #\:) "false")))
          (with-env
           "FONT_PAGES_INSPECTOR" failed-inspector
           (lambda ()
             (let ((result (build-result catalog inputs)))
               (test-assert "Changed inspector cannot reuse stale face metadata"
                 (and (= 1 (car result))
                      (string-contains (cdr result) "Command failed")
                      (string-contains (cdr result) failed-inspector)
                      (string-contains (cdr result) "\"inspect\"")))))))
        (test-equal "Failed builds preserve the entire previous site"
          snapshot (published-files))
        (let ((missing-image (string-append temporary "/missing.webp")))
          (render-jobs
           (list (list (string-append fixtures "/static.ttf") "0" "-" "en" "AZ"
                       missing-image)))
          (test-assert
            "Renderer rejects missing glyphs without system fallback"
            (and (not (file-exists? missing-image))
                 (file-exists? (string-append missing-image ".unsupported")))))
        (let ((invalid-job (string-append temporary "/invalid.tsv"))
              (unwritable-job (string-append temporary "/unwritable.tsv")))
          (write-text invalid-job
                      (string-append
                       fixtures "/static.ttf\tnot-an-index\t-\ten\tA\t"
                       temporary "/invalid.webp\n"))
          (write-text unwritable-job
                      (string-append
                       fixtures "/static.ttf\t0\t-\ten\tA\t"
                       temporary "/absent/sample.webp\n"))
          (for-each
           (lambda (case)
             (let ((result
                    (command-result
                     (lambda ()
                       (system* (getenv "FONT_PAGES_RENDERER") (car case))))))
               (test-assert (cdr case)
                 (and (eqv? 1 (status:exit-val (car result)))
                      (string-contains (cdr result) (cdr case))))))
           `((,invalid-job . "Invalid font face index")
             (,unwritable-job . "Cannot write")
             (,temporary . "Cannot read sample manifest"))))
        (for-each
         (lambda (case)
           (let ((result
                  (command-result
                   (lambda ()
                     (system* (getenv "FONT_PAGES_INSPECTOR") "image-info"
                              (string-append temporary "/" (car case)))))))
             (test-assert (cdr case)
               (and (eqv? 1 (status:exit-val (car result)))
                    (string-contains (cdr result) (cdr case))))))
         '(("blank.webp" . "Expected nonblank WebP")
           ("opaque.webp" . "Expected transparent WebP")
           ("edge.webp" . "Expected transparent WebP borders")
           ("lossy.webp" . "Expected static lossless WebP")
           ("truncated.webp" . "Invalid WebP pixels"))))))
  (lambda () (delete-tree temporary)))

(test-end "publication")
(exit (and (zero? (test-runner-fail-count runner))
           (zero? (test-runner-xpass-count runner))))
