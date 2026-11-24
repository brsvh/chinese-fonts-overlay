(use-modules (archive)
             (util)
             (ice-9 match))

(match (cdr (command-line))
  (("validate" manifest)
   (display (release-name (validate-release (read-json manifest))))
   (newline))
  (("pack" directory source destination)
   (pack-site directory source destination))
  (("unpack" archive manifest destination)
   (unpack-site archive (read-json manifest) destination))
  (_ (error (string-append "Expected pack DIRECTORY REVISION DESTINATION "
                            "or unpack ARCHIVE MANIFEST DESTINATION or validate MANIFEST"))))
