(use-modules (chinese-fonts-overlay pages util)
             (ice-9 match)
             (srfi srfi-1))

(define (output-path path)
  "Resolve PATH through existing parents, normalizing symlinks and dot segments."
  (let ((trimmed (if (string=? path "/") "/" (string-trim-right path #\/))))
    (cond ((file-exists? trimmed) (canonicalize-path trimmed))
          ((false-if-exception (lstat trimmed))
           (error "Invalid output path" trimmed))
          (else
           (let ((parent (dirname trimmed))
                 (name (basename trimmed)))
             (cond ((string=? name ".") (output-path parent))
                   ((string=? name "..") (dirname (output-path parent)))
                   (else (in-vicinity (output-path parent) name))))))))

(define (within? path directory)
  "Whether PATH is DIRECTORY or one of its descendants."
  (or (string=? path directory)
      (string-prefix? (string-append directory "/") path)))

(define (check-output source path)
  "Reject an output that could overwrite the checkout's handwritten sources."
  (let* ((output (output-path path))
         (pages (canonicalize-path source))
         (root (dirname pages)))
    (when (or (string=? output "/") (within? pages output)
              (any (lambda (name) (within? output (string-append pages "/" name)))
                   '("build-aux" "doc" "etc" "module" "src" "test" "web"))
              (any (lambda (name) (within? output (string-append root "/" name)))
                   '(".agents" ".git" ".github" "ci" "lib" "overlays" "packages" "tools")))
      (error "Output directory overlaps the source tree" output))))

(define (clean source directory names)
  "Remove the named products from a checked output directory."
  (check-output source directory)
  (for-each (lambda (name) (delete-tree (string-append directory "/" name))) names))

(match (cdr (command-line))
  (("check" source directories ...)
   (for-each (lambda (directory) (check-output source directory)) directories))
  (("clean-build" source directory)
   (clean source directory
          '("bin" "web" "inputs" "test" "previews" "public" "manual"
            "manual.sha256" "reference.json" "reference.sha256" "native.settings"
            "web.settings" "previews.sha256" "public.sha256")))
  (("clean-cache" source directory)
   (clean source directory '("font-records" "language-images")))
  (_ (error "Expected check|clean-build|clean-cache SOURCE DIRECTORY ...")))
