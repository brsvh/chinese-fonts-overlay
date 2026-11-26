(use-modules (ice-9 format)
             (ice-9 ftw)
             (ice-9 getopt-long)
             (ice-9 match)
             (ice-9 popen)
             (ice-9 regex)
             (ice-9 textual-ports)
             (json)
             (srfi srfi-1)
             (web uri))

(define* (jref object key #:optional (fallback #f))
  "Read KEY from a JSON object alist, or return FALLBACK."
  (let ((entry (assoc key object)))
    (if entry (cdr entry) fallback)))

(define (jarray value)
  "Return a list view of a JSON array."
  (if (vector? value) (vector->list value) value))

(define (write-json file value)
  "Write VALUE atomically as private UTF-8 JSON followed by a newline."
  (atomic-write
   file
   (lambda (port)
     (display (scm->json-string value) port)
     (newline port))
   #o600))

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
  (let ((info (false-if-exception (lstat path))))
    (when info
      (if (eq? 'directory (stat:type info))
          (let ((entries
                 (scandir path (lambda (name) (not (member name '("." "..")))))))
            (when entries
              (for-each
               (lambda (name) (delete-tree (string-append path "/" name)))
               entries)
              (rmdir path)))
          (delete-file path)))))

(define (files-under path)
  "List regular files beneath PATH in sorted order, following directory symlinks safely."
  (let walk ((directory path) (visited '()))
    (let ((info (false-if-exception (stat directory))))
      (if (or (not info) (not (eq? 'directory (stat:type info))))
          '()
          (let ((key (cons (stat:dev info) (stat:ino info))))
            (if (member key visited)
                '()
                (let ((entries (scandir directory
                                        (lambda (name)
                                          (not (member name '("." ".."))))
                                        string<?)))
                  (if (not entries)
                      '()
                      (append-map
                       (lambda (name)
                         (let* ((file (string-append directory "/" name))
                                (entry (false-if-exception (stat file))))
                           (cond
                            ((not entry) '())
                            ((eq? 'directory (stat:type entry))
                             (walk file (cons key visited)))
                            (else (list file)))))
                       entries)))))))))

(define (run . args)
  "Execute the argument vector ARGS and fail on a nonzero exit status."
  (let ((status (apply system* args)))
    (unless (zero? status)
      (error "Command failed" args status))))

(define (capture . args)
  "Capture UTF-8 stdout from ARGS; propagate a nonzero exit status."
  (let ((port (apply open-pipe* OPEN_READ args))
        (status #f))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (set-port-encoding! port "UTF-8")
          (let ((text (get-string-all port)))
            (set! status (close-pipe port))
            (set! port #f)
            (unless (zero? status)
              (error "Command failed" args status))
            text))
        (lambda ()
          (when port
            (close-pipe port))))))

(define (temporary-directory parent)
  "Create and return an absolute private temporary directory under PARENT."
  (mkdir-p parent)
  (canonicalize-path (mkdtemp (string-append parent "/.font-languages-XXXXXX"))))

(define* (atomic-write file writer #:optional explicit-mode)
  "Replace FILE on success, using EXPLICIT-MODE or preserving existing permissions."
  (mkdir-p (dirname file))
  (let* ((mode (or explicit-mode
                   (and (file-exists? file) (stat:perms (stat file)))))
         (port (mkstemp (string-append file ".XXXXXX")))
         (temporary (port-filename port))
         (renamed? #f))
    (dynamic-wind
        (lambda () #t)
        (lambda ()
          (set-port-encoding! port "UTF-8")
          (writer port)
          (when mode (chmod port mode))
          (close-port port)
          (set! port #f)
          (rename-file temporary file)
          (set! renamed? #t))
        (lambda ()
          (when (and port (not (port-closed? port)))
            (false-if-exception (close-port port)))
          (when (and (not renamed?) (file-exists? temporary))
            (false-if-exception (delete-file temporary)))))))

(define (font-file? path)
  "Recognize supported original font file suffixes without case sensitivity."
  (any (lambda (suffix) (string-suffix? suffix (string-downcase path)))
       '(".ttf" ".otf" ".ttc" ".otc")))

(define (language-tag? value)
  "Recognize the Fontconfig language-tag syntax accepted by package metadata."
  (and (string? value) (string-match "^[a-z]{2,3}(-[a-z0-9]{2,8})*$" value)))

(define (nonempty-env name fallback)
  "Return the value of environment variable NAME when nonempty, else FALLBACK."
  (let ((value (getenv name)))
    (if (and value (not (string-null? value))) value fallback)))

(define (scanner-program)
  "Return the native font scanner executable name or override path."
  (nonempty-env "FONT_LANGUAGES_SCANNER" "chinese-fonts-overlay-scan-font"))

(define (parse-face-record directory file entry)
  "Validate one scanner face object ENTRY and attach its relative FILE path."
  (unless (list? entry)
    (error "Invalid scanner face record" file entry))
  (let* ((index (jref entry "index"))
         (family (jref entry "family"))
         (style (jref entry "style"))
         (raw-languages (jref entry "languages"))
         (languages
          (and (or (vector? raw-languages) (list? raw-languages))
               (let ((tags (jarray raw-languages)))
                 (and (every language-tag? tags)
                      (sort (delete-duplicates tags) string<?))))))
    (unless (and (exact-integer? index) (>= index 0)
                 (string? family) (string? style) languages)
      (error "Invalid scanner face record" file entry))
    `(("file" . ,(substring file (+ 1 (string-length directory))))
      ("index" . ,index)
      ("family" . ,family)
      ("style" . ,style)
      ("languages" . ,(list->vector languages)))))

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
   (list "--" (string-append "FONTCONFIG_FILE=" configuration) "LC_ALL=C")))

(define (scan-font-file directory file environment)
  "Read every face in FILE using isolated ENVIRONMENT arguments."
  (let* ((text (apply capture "env"
                      (append environment (list (scanner-program) file))))
         (parsed (json-string->scm text))
         (entries (and (or (vector? parsed) (list? parsed))
                       (jarray parsed))))
    (unless (and entries (pair? entries))
      (error "Font scanner returned no faces" file))
    (map (lambda (entry) (parse-face-record directory file entry))
         entries)))

(define (scan-fonts directory)
  "Scan every face in DIRECTORY with isolated Fontconfig configuration."
  (let ((files (filter font-file? (files-under directory))))
    (when (null? files)
      (error "No OTF/TTF/OTC/TTC fonts" directory))
    (let* ((temporary (temporary-directory (nonempty-env "TMPDIR" "/tmp")))
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
          (lambda () (false-if-exception (delete-tree temporary)))))))

(define (replace-languages source languages)
  "Replace only the website metadata's literal language list in Nix SOURCE."
  (unless (and (every language-tag? languages)
               (equal? languages (sort (delete-duplicates languages) string<?)))
    (error "Expected sorted, unique Fontconfig language tags"))
  (let ((starts
         (list-matches
          (make-regexp "^( +)chinese-fonts-overlay-pages = \\{[[:space:]]*$"
                       regexp/newline)
          source)))
    (unless (= 1 (length starts))
      (error "Expected exactly one literal chinese-fonts-overlay-pages block"))
    (let* ((start (car starts))
           (indent (match:substring start 1))
           (tail (substring source (match:end start)))
           (end (regexp-exec
                 (make-regexp (string-append "^" indent "\\};") regexp/newline)
                 tail)))
      (unless end
        (error "Cannot locate the end of chinese-fonts-overlay-pages"))
      (let* ((block (substring tail 0 (match:start end)))
             (matches
              (list-matches
               (make-regexp
                "^( +)languages = \\[[[:space:]\"a-z0-9-]*\\];"
                regexp/newline)
               block)))
        (unless (= 1 (length matches))
          (error
           "Expected one literal languages list inside chinese-fonts-overlay-pages"))
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
         "--"
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
  "Capture the Fontconfig version reported by the native scanner."
  (string-trim-both (capture (scanner-program) "--version")))

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
                     "entry.package.chinese-fonts-overlay-pages.languages; "
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
                     (lambda (port) (display (cdr entry) port))))
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

(define (update-font-languages options)
  "Scan packages selected by OPTIONS and optionally check or update coverage."
  (let* ((selected (append (option-ref options '() '())
                           (filter-map
                            (lambda (entry)
                              (and (eq? (car entry) 'package) (cdr entry)))
                            options)))
         (all? (option-ref options 'all #f))
         (write? (option-ref options 'write #f))
         (check? (option-ref options 'check #f))
         (source-root
          (canonicalize-path (or (option-ref options 'source-root #f) (checkout)))))
    (when (or (and all? (pair? selected)) (and (not all?) (null? selected)))
      (error "Specify package attributes, package.nix paths, or --all"))
    (when (and write? check?)
      (error "Use either --write or --check"))
    (let* ((sources (package-sources source-root))
           (identifiers (if all? (sort (map car sources) string<?)
                            (resolve-packages selected sources)))
           (packages (realize-packages source-root identifiers))
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
          0))))

(define (checkout)
  "Locate the repository above the current directory."
  (let loop ((directory (getcwd)))
    (cond ((file-exists? (string-append directory "/.git")) directory)
          ((string=? directory (dirname directory))
           (error "Use --source-root to select the font repository"))
          (else (loop (dirname directory))))))

(define (scan-command arguments)
  "Parse ARGUMENTS once and return the scanner's exit status."
  (set-port-encoding! (current-output-port) "UTF-8")
  (set-port-encoding! (current-error-port) "UTF-8")
  (catch #t
    (lambda ()
      (let ((options
             (getopt-long (cons "update-font-languages" arguments)
                         '((help) (package (value #t)) (all) (write) (check)
                           (output (value #t)) (source-root (value #t))))))
        (if (or (null? arguments) (option-ref options 'help #f))
            (begin
              (display "Usage: chinese-fonts-overlay-update-font-languages [OPTIONS] PACKAGE...

PACKAGE is a full attribute (naverPackages.maru-buri) or a package.nix path.
  --package PACKAGE   Select another package (repeatable).
  --all               Select every package in the repository.
  --check             Fail if recorded language coverage is stale.
  --write             Update language lists after all scans succeed.
  --output FILE       Write the coverage report to FILE instead of stdout.
  --source-root DIR   Select the repository explicitly.
  --help              Show this help.

Without --check or --write, only report detected coverage.
")
              0)
            (update-font-languages options))))
    (lambda (key . arguments)
      (print-exception (current-error-port) #f key arguments)
      1)))

(define (main argv)
  "Run the command-line entry point with ARGV and exit with its status."
  (exit (scan-command (cdr argv))))
