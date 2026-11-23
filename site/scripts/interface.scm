(use-modules (chinese-fonts-overlay-site interface)
             (ice-9 match))

(match (cdr (command-line))
  ((output) (prepare-interface (getenv "MB_TYPE_DIR") output))
  (_ (error "Usage: interface.scm OUTPUT")))
