(define-module (chinese-fonts-overlay-update-font-languages coverage)
  #:use-module (chinese-fonts-overlay-update-font-languages util)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 match)
  #:use-module (json)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (web uri)
  #:export (scan-fonts replace-languages resolve-packages update-font-languages))

(define (font-file? path)
  "Recognize supported original font file suffixes without case sensitivity."
  (any (lambda (suffix) (string-suffix? suffix (string-downcase path)))
       '(".ttf" ".otf" ".ttc" ".otc")))

(define (language-tag? value)
  "Recognize the Fontconfig language-tag syntax accepted by package metadata."
  (and (string? value) (string-match "^[a-z]{2,3}(-[a-z0-9]{2,8})*$" value)))

(define (parse-charset text file)
  "Parse ordered Fontconfig hex ranges in TEXT; reject malformed FILE data."
  (let loop ((tokens (string-tokenize text)) (previous -1) (ranges '()))
    (if (null? tokens)
        (reverse ranges)
        (let* ((token (car tokens))
               (match (string-match "^([0-9a-fA-F]+)(-([0-9a-fA-F]+))?$" token))
               (first (and match (string->number (match:substring match 1) 16)))
               (last (and match
                          (string->number (or (match:substring match 3)
                                              (match:substring match 1))
                                          16))))
          (unless (and first last (< previous first) (<= first last #x10ffff))
            (error "Invalid Fontconfig charset" file token))
          (loop (cdr tokens) last (cons (cons first last) ranges))))))

(define (covers-range? ranges first last)
  "Check that ordered RANGES cover every code point from FIRST through LAST."
  (let loop ((ranges ranges) (next first))
    (and (pair? ranges)
         (let ((range (car ranges)))
           (cond
            ((< (cdr range) next) (loop (cdr ranges) next))
            ((> (car range) next) #f)
            ((>= (cdr range) last) #t)
            (else (loop (cdr ranges) (+ 1 (cdr range)))))))))

(define (modern-korean? ranges)
  "Recognize complete modern Hangul syllables and compatibility jamo in RANGES."
  ;; Fontconfig also requires archaic compatibility jamo (U+3165-U+318E).
  ;; Unicode 17, section 18.6 defines the 11,172 modern precomposed syllables.
  (and (covers-range? ranges #x3131 #x3163)
       (covers-range? ranges #xac00 #xd7a3)))

(define (parse-scan-line directory file line)
  "Parse one Fontconfig face row, rejecting malformed output with FILE context."
  (match (string-split line #\tab)
    ((index-text family style language-text charset-text)
     (let ((index (string->number index-text))
           (languages
            (sort
             (delete-duplicates
              (append (delete "" (string-split language-text #\|))
                      (if (modern-korean? (parse-charset charset-text file))
                          '("ko")
                          '())))
             string<?)))
       (unless (and (exact-integer? index) (>= index 0)
                    (every language-tag? languages))
         (error "Invalid Fontconfig face" file line))
       `(("file" . ,(substring file (+ 1 (string-length directory))))
         ("index" . ,index)
         ("family" . ,family)
         ("style" . ,style)
         ("languages" . ,(list->vector languages)))))
    (_ (error "Expected five Fontconfig fields" file line))))

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
                              (string-append
                               "%{index}\t%{family[0]}\t%{style[0]}\t"
                               "%{lang}\t%{charset}\n")
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

(define (package-command root identifiers arguments result)
  "Build a Nix command for RESULT, passing input paths and names as data."
  (append
   (list "env"
         (string-append "FONT_LANGUAGES_SOURCE_ROOT=" root)
         (string-append "FONT_LANGUAGES_SOURCE_FLAKE=git+file://"
                        (string-join (map uri-encode (string-split root #\/))
                                     "/"))
         (string-append "FONT_LANGUAGES_IDENTIFIERS="
                        (scm->json-string (list->vector identifiers)))
         "nix")
   arguments
   (list
    "--impure" "--expr"
    (string-append
     "let
  root = builtins.getEnv \"FONT_LANGUAGES_SOURCE_ROOT\";
  flake = builtins.getFlake (builtins.getEnv \"FONT_LANGUAGES_SOURCE_FLAKE\");
  pkgs = import flake.inputs.nixpkgs {
    config = { allowUnfree = true; };
    overlays = [ (import (root + \"/default.nix\")) ];
  };
  inherit (pkgs.lib) concatStringsSep getAttrFromPath head splitString tail;
  selected = map (id:
    let parts = splitString \".\" id;
    in {
      inherit id;
      package = getAttrFromPath [
        (head parts)
        (concatStringsSep \".\" (tail parts))
      ] pkgs;
    }) (builtins.fromJSON (builtins.getEnv \"FONT_LANGUAGES_IDENTIFIERS\"));
in "
     result))))

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
          (cons (string-append vendor "Packages." name) file))
         (_ #f)))
     (files-under directory))))

(define (realize-packages root identifiers)
  "Evaluate IDENTIFIERS in ROOT and build missing font outputs for scanning."
  (let* ((packages
          (jarray
           (json-string->scm
            (apply capture
                   (package-command
                    root identifiers '("eval" "--json")
                    (string-append
                     "map (entry: { inherit (entry) id; "
                     "path = toString entry.package; "
                     "languages = "
                     "entry.package.chinese-fonts-overlay-site.languages; "
                     "}) selected"))))))
         (missing (filter (lambda (package)
                            (not (file-exists? (jref package "path"))))
                          packages)))
    (unless (null? missing)
      (apply run
             (package-command
              root (map (lambda (package) (jref package "id")) missing)
              '("build" "--no-link")
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

(define (resolve-packages selectors sources)
  "Resolve attribute names or package.nix paths in SELECTORS against SOURCES."
  (sort
   (delete-duplicates
    (map (lambda (selector)
           (cond
            ((assoc selector sources) selector)
            ((file-exists? selector)
             (let* ((path (canonicalize-path selector))
                    (entry (find (lambda (entry) (string=? path (cdr entry)))
                                 sources)))
               (if entry (car entry)
                   (error "Not a package.nix in this repository" selector))))
            (else (error "Unknown package attribute or package.nix path"
                         selector))))
         selectors))
   string<?))

(define (update-font-languages root arguments)
  "Scan selected packages and optionally check or replace their language lists."
  (let* ((options
          (getopt-long
           (cons "update-font-languages" arguments)
           '((package (value #t))
             (all (value #f))
             (write (value #f))
             (check (value #f))
             (output (value #t))
             (source-root (value #t)))))
         (selected (append (option-ref options '() '())
                           (filter-map
                            (lambda (entry)
                              (and (eq? (car entry) 'package) (cdr entry)))
                            options)))
         (all? (option-ref options 'all #f))
         (write? (option-ref options 'write #f))
         (check? (option-ref options 'check #f))
         (source-root
          (canonicalize-path (option-ref options 'source-root root))))
    (when (or (and all? (pair? selected)) (and (not all?) (null? selected)))
      (error "Specify package attributes, package.nix paths, or --all"))
    (when (and write? check?)
      (error "Use either --write or --check"))
    (let* ((sources (package-sources source-root))
           (identifiers (if all? (sort (map car sources) string<?)
                            (resolve-packages selected sources))))
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
