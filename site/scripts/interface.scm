(use-modules (chinese-fonts-overlay-site interface)
             (ice-9 match))

(match (cdr (command-line))
  ((output) (prepare-interface output))
  (_ (error "Usage: interface.scm OUTPUT")))
