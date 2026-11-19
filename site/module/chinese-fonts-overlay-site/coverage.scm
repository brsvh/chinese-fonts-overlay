(define-module (chinese-fonts-overlay-site coverage)
  #:use-module (chinese-fonts-overlay-site util)
  #:use-module (chinese-fonts-overlay-site previews)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 match)
  #:use-module (json)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:export (scan-fonts replace-languages update-font-info))

(define (language-tag? value)
  "Recognize the Fontconfig language-tag syntax accepted by package metadata."
  (and (string? value) (string-match "^[a-z]{2,3}(-[a-z0-9]{2,8})*$" value)))

(define (parse-scan-line directory file line)
  "Parse one Fontconfig face row, rejecting malformed output with FILE context."
  (match (string-split line #\tab)
    ((index-text family style language-text)
     (let ((index (string->number index-text))
           (languages
            (sort (delete-duplicates (delete "" (string-split language-text #\|)))
                  string<?)))
       (unless (and (exact-integer? index) (>= index 0)
                    (every language-tag? languages))
         (error "Invalid Fontconfig face" file line))
       `(("file" . ,(substring file (+ 1 (string-length directory))))
         ("index" . ,index)
         ("family" . ,family)
         ("style" . ,style)
         ("languages" . ,(list->vector languages)))))
    (_ (error "Expected four Fontconfig fields" file line))))

(define (fontconfig-environment configuration)
  "Build env arguments that isolate Fontconfig using CONFIGURATION."
  (append
   (append-map
    (lambda (entry)
      (let ((key (car (string-split entry #\=))))
        (if (or (string-prefix? "FONTCONFIG_" key)
                (member key '("FC_DEBUG" "FC_LANG")))
            (list "-u" key)
            '())))
    (environ))
   (list (string-append "FONTCONFIG_FILE=" configuration) "LC_ALL=C")))

(define (scan-font-file directory file environment)
  "Read every face in FILE using isolated ENVIRONMENT arguments."
  (let ((text
         (apply capture "env"
                (append environment
                        (list "fc-scan" "--format"
                              "%{index}\t%{family[0]}\t%{style[0]}\t%{lang}\n"
                              file)))))
    (when (string-null? (string-trim-both text))
      (error "Fontconfig returned no faces" file))
    (map (lambda (line) (parse-scan-line directory file line))
         (delete "" (string-split text #\newline)))))

(define (scan-fonts directory)
  "Scan every face in DIRECTORY with isolated Fontconfig configuration."
  (let ((files (filter font-file? (files-under directory))))
    (when (null? files)
      (error "No OTF/TTF/OTC/TTC fonts" directory))
    (let* ((temporary (temporary-directory (or (getenv "TMPDIR") "/tmp")))
           (configuration (string-append temporary "/fonts.conf")))
      (dynamic-wind
        (lambda () #t)
        (lambda ()
          (write-text configuration
                      "<?xml version=\"1.0\"?><fontconfig></fontconfig>\n")
          (let* ((environment (fontconfig-environment configuration))
                 (faces (append-map
                         (lambda (file)
                           (scan-font-file directory file environment))
                         files)))
            `(("languages" .
               ,(list->vector
                 (sort (delete-duplicates
                        (append-map
                         (lambda (face) (jarray (jref face "languages")))
                         faces))
                       string<?)))
              ("faces" . ,(list->vector faces)))))
        (lambda () (delete-tree temporary))))))

(define (replace-languages source languages)
  "Replace only the website metadata's literal language list in Nix SOURCE."
  (unless (and (every language-tag? languages)
               (equal? languages (sort (delete-duplicates languages) string<?)))
    (error "Expected sorted, unique Fontconfig language tags"))
  (let ((starts
         (list-matches
          (make-regexp "^( +)chinese-fonts-overlay-site = \\{[[:space:]]*$"
                       regexp/newline)
          source)))
    (unless (= 1 (length starts))
      (error "Expected exactly one literal chinese-fonts-overlay-site block"))
    (let* ((start (car starts))
           (indent (match:substring start 1))
           (tail (substring source (match:end start)))
           (end (regexp-exec
                 (make-regexp (string-append "^" indent "\\};") regexp/newline)
                 tail)))
      (unless end
        (error "Cannot locate the end of chinese-fonts-overlay-site"))
      (let* ((block (substring tail 0 (match:start end)))
             (matches
              (list-matches
               (make-regexp
                "^( +)languages = \\[[[:space:]\"a-z0-9-]*\\];"
                regexp/newline)
               block)))
        (unless (= 1 (length matches))
          (error
           "Expected one literal languages list inside chinese-fonts-overlay-site"))
        (let* ((match (car matches))
               (padding (match:substring match 1))
               (replacement
                (string-append
                 padding
                 "languages = ["
                 (if (null? languages)
                     " "
                     (string-append
                      "\n"
                      (string-concatenate
                       (map (lambda (tag)
                              (string-append padding "  \"" tag "\"\n"))
                            languages))
                      padding))
                 "];")))
          (string-append
           (substring source 0 (match:end start))
           (substring block 0 (match:start match))
           replacement
           (substring block (match:end match))
           (substring tail (match:start end))))))))

(define (package-expression root identifiers)
  "Select IDENTIFIERS from ROOT with a Nix expression, without shell parsing."
  (string-append
   "let root = "
   (scm->json-string root)
   "; flake = builtins.getFlake "
   (scm->json-string (string-append "git+file://" root))
   "; "
   "pkgs = import flake.inputs.nixpkgs { "
   "config = { allowUnfree = true; }; "
   "overlays = [ (import (root + \"/default.nix\")) ]; }; selected = [ "
   (string-join
    (map (lambda (id)
           (let* ((dot (string-index id #\.))
                  (vendor (substring id 0 dot))
                  (name (substring id (+ dot 1))))
             (string-append
              "{ id = "
              (scm->json-string id)
              "; package = pkgs."
              vendor
              "Packages."
              (scm->json-string name)
              "; }")))
         identifiers)
    " ")
   " ]; in "))

(define (scanner-version)
  "Capture the Fontconfig version reported on stderr."
  (let* ((directory (temporary-directory (or (getenv "TMPDIR") "/tmp")))
         (file (string-append directory "/version")))
    (dynamic-wind
      (lambda () #t)
      (lambda ()
        (call-with-output-file
            file
          (lambda (port)
            (with-error-to-port port (lambda () (run "fc-scan" "--version")))))
        (string-trim-both (read-text file)))
      (lambda () (delete-tree directory)))))

(define (package-sources root)
  "Index package identifiers and their source files beneath ROOT."
  (let ((directory (string-append root "/packages")))
    (filter-map
     (lambda (file)
       (match (string-split (substring file (+ 1 (string-length directory)))
                            #\/)
         ((vendor name "package.nix")
          (cons (string-append vendor "." name) file))
         (_ #f)))
     (files-under directory))))

(define (realize-packages root identifiers)
  "Evaluate IDENTIFIERS in ROOT and build missing font outputs for scanning."
  (let* ((expression (package-expression root identifiers))
         (packages
          (jarray
           (json-string->scm
            (capture "nix" "eval" "--impure" "--json" "--expr"
                     (string-append
                      expression
                      "map (entry: { inherit (entry) id; "
                      "path = toString entry.package; "
                      "languages = "
                      "entry.package.chinese-fonts-overlay-site.languages; "
                      "}) selected")))))
         (missing (filter (lambda (package)
                            (not (file-exists? (jref package "path"))))
                          packages)))
    (unless (null? missing)
      (run "nix" "build" "--impure" "--no-link" "--expr"
           (string-append
            (package-expression root (map (lambda (package) (jref package "id"))
                                          missing))
            "map (entry: entry.package) selected")))
    packages))

(define (write-language-updates! packages coverage sources)
  "Prepare all language replacements before writing any package source."
  (let ((replacements
         (map (lambda (package)
                (let* ((id (jref package "id"))
                       (file (jref sources id)))
                  (cons file
                        (replace-languages
                         (read-text file)
                         (jarray (jref (jref coverage id) "languages"))))))
              packages)))
    (for-each
     (lambda (entry)
       (atomic-write (car entry)
                     (lambda (file) (write-text file (cdr entry)))))
     replacements)))

(define (update-font-info root arguments)
  "Scan selected packages and optionally check or replace their language lists."
  (let* ((options
          (getopt-long
           (cons "update-font-info" arguments)
           '((package (value #t))
             (all (value #f))
             (write (value #f))
             (check (value #f))
             (output (value #t))
             (source-root (value #t)))))
         (selected (filter-map
                    (lambda (entry)
                      (and (eq? (car entry) 'package) (cdr entry)))
                    options))
         (all? (option-ref options 'all #f))
         (write? (option-ref options 'write #f))
         (check? (option-ref options 'check #f))
         (source-root
          (canonicalize-path (option-ref options 'source-root root))))
    (when (or (and all? (pair? selected)) (and (not all?) (null? selected)))
      (error "Specify --package or --all"))
    (when (and write? check?)
      (error "Use either --write or --check"))
    (unless (null? (option-ref options '() '()))
      (error "Unexpected positional arguments"))
    (let* ((sources (package-sources source-root))
           (identifiers (sort (delete-duplicates (if all? (map car sources) selected))
                              string<?)))
      (unless (every (lambda (id) (assoc id sources)) identifiers)
        (error "Unknown package" identifiers))
      (let* ((packages (realize-packages source-root identifiers))
             (coverage (map (lambda (package)
                              (cons (jref package "id")
                                    (scan-fonts (jref package "path"))))
                            packages))
             (changed
              (filter (lambda (package)
                        (not (equal? (jref package "languages")
                                     (jref (jref coverage (jref package "id"))
                                           "languages"))))
                      packages))
             (report `(("scanner" . ,(scanner-version))
                       ("packages" . ,coverage)))
             (output (option-ref options 'output #f)))
        (when write?
          (write-language-updates! changed coverage sources))
        (if output
            (write-json output report)
            (begin (scm->json report) (newline)))
        (if (and check? (pair? changed))
            (begin
              (format (current-error-port) "Outdated language coverage: ~a~%"
                      (map (lambda (package) (jref package "id")) changed))
              1)
            0)))))
