(use-modules (chinese-fonts-overlay pages presentation fonts)
             (ice-9 match))

(match (cdr (command-line))
  ((output) (prepare-interface (getenv "MB_TYPE_DIR") output))
  (_ (error "Usage: fonts.scm OUTPUT")))
