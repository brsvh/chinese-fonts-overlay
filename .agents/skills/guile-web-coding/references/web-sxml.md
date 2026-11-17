# SXML and HTML

Read only when producing web markup or changing its serialization. For transport
and response encoding, read [Web and HTTP](web-http.md). Preserve the project's
current styling scope; HTML generation does not require Tailwind, DaisyUI, or a
component framework.

## Represent markup before writing it

Use ordinary SXML data for components where practical: a tag, an optional
`(@ ...)` attribute list, and children. Build components from explicit
arguments; keep response headers, filesystem reads, and scheduler startup out of
reusable markup procedures. Share helpers when actual call sites benefit rather
than inventing a component framework.

Keep data as text or attribute values until serialization. Do not pre-escape it
and then send it through an escaping serializer. For example:

```scheme
(use-modules (web uri))

(define (entry-link slug title)
  "Return an SXML link with SLUG encoded as one path segment."
  `(a (@ (href ,(string-append "/entries/" (uri-encode slug))))
      ,title))
```

The route above is illustrative, not an application route requirement. Encoding
the slug does not HTML-escape the title; the serializer handles text and
attribute escaping later.

## Select the actual serializer

Guile's `(sxml simple)` provides `sxml->xml`, an XML serializer. Its
`sxml->string` procedure detags a tree; it does not produce serialized markup.
Do not assume an XML serialization is suitable for an HTML document merely
because simple links look correct.

Check these differences when choosing or reviewing HTML output:

- HTML void elements and empty non-void elements have different closing rules.
  In particular, an XML-style `<script />` is not a closed HTML script element.
- HTML `script` and `style` elements use raw-text rules. Ordinary HTML escaping
  is not a general-purpose safe encoder for embedding arbitrary data in them.
  Prefer an established external-resource or data-transfer contract; if inline
  content is required, use context-specific encoding and test closing-tag input.
- Boolean attributes have presence semantics in HTML. Emit the supported shape
  or omit the attribute; do not serialize a false Scheme value as a string and
  assume it disables the attribute.
- Doctype and special-node forms are serializer-specific. Guile's `*TOP*`,
  `*PI*`, and `*ENTITY*` nodes are not interchangeable with another library's
  special forms.

Haunt's `(haunt html)` is a compact community implementation to study. It
exposes `sxml->html` and `sxml->html-string`, recognizes `(doctype "html")`,
closes empty non-void elements, and writes script/style contents raw. Its
historic void-tag list and other choices are not a complete normative HTML
specification. Studying it does not require adopting Haunt as an application
dependency or copying its serializer into the project.

When Haunt is the chosen serializer, the previous component can be rendered as:

```scheme
(use-modules (haunt html))

(sxml->html-string (entry-link "naïve /" "A < B & C"))
;; => "<a href=\"/entries/na%C3%AFve%20%2F\">A &lt; B &amp; C</a>"
```

Use the project's selected HTML serializer in production, verify its contract,
and avoid claiming this Haunt call is available in base Guile.

## Escaping does not validate a tree

Keep tag and attribute names under program control unless the application has an
explicit validator for them. Validate URL schemes and destinations separately
from attribute escaping where user-supplied URLs are accepted. Escaping text
cannot make an arbitrary event-handler attribute or script body safe.

Guile's XML serializer can execute procedure-valued nodes, and raw/special nodes
can bypass ordinary text handling. Do not accept an arbitrary SXML tree as inert
untrusted data. Construct a permitted representation from validated content at
the trust boundary; use the application's chosen sanitizer if rich HTML input is
intentionally supported.

## Verify output semantics

Check text and attribute values containing `&`, `<`, quotes, and Unicode against
the selected serializer. Test empty `script`, ordinary empty elements, void
elements, and omitted boolean attributes when those cases are changed. Include
raw-text closing-tag cases when inline content is involved.

Assert output bytes or DOM behavior according to the contract. A string match
does not prove how HTML is parsed; use browser inspection when parser behavior,
component layout, accessibility, or Hoot event attachment is the changed
outcome. Keep CSS and interaction tests with their responsible skills.

## Source basis

- [Guile 3.0.11 SXML implementation](https://codeberg.org/guile/guile/src/tag/v3.0.11/module/sxml/simple.scm),
  `doc/ref/sxml.texi`, and `test-suite/tests/sxml.simple.test` establish XML
  conversion, escaping, special nodes, and procedure handling.
- [Haunt HTML implementation at a154de4a](https://git.dthompson.us/haunt/tree/haunt/html.scm?id=a154de4a02cfb11c185a851170400ad83b1c914e)
  and its `tests/html.scm` demonstrate a separate HTML serializer. The upstream
  test is narrow; it is not evidence that every HTML edge case is covered.
