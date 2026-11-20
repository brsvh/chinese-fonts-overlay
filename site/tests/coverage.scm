(use-modules (chinese-fonts-overlay-site coverage)
             (chinese-fonts-overlay-site util)
             (srfi srfi-1)
             (srfi srfi-64))

(test-begin "coverage")

(define runner (test-runner-current))

(define source
  "{
  passthru = {
    chinese-fonts-overlay-site = {
      displayName = \"测试字体\";
      languages = [ \"en\" ];
      licenseCost = \"free\";
      styles = [ \"sans\" ];
      vendor = \"test\";
    };
  };
}
")

(test-equal "Replace only language list"
  "{
  passthru = {
    chinese-fonts-overlay-site = {
      displayName = \"测试字体\";
      languages = [
        \"en\"
        \"zh-cn\"
      ];
      licenseCost = \"free\";
      styles = [ \"sans\" ];
      vendor = \"test\";
    };
  };
}
"
  (replace-languages source '("en" "zh-cn")))

(test-equal "Refuse to rewrite an unrecognized source file"
  "Expected exactly one literal chinese-fonts-overlay-site block"
  (catch 'misc-error
    (lambda () (replace-languages "{}" '("en")))
    (lambda (key subr message arguments data) (car arguments))))

(let ((coverage (scan-fonts (getenv "FONT_SITE_FIXTURES"))))
  (test-equal "Coverage report includes both collection members"
    '((0 "First") (1 "Second"))
    (map (lambda (face) (list (jref face "index") (jref face "family")))
         (filter (lambda (face) (equal? (jref face "file") "collection.ttc"))
                 (jarray (jref coverage "faces"))))))

(test-end "coverage")

(exit (zero? (test-runner-fail-count runner)))
