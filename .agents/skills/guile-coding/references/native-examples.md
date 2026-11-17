# Native Guile Examples

Read the sections relevant to the change. These are original teaching examples
based on inspected community practices, not verbatim upstream implementations or
proposed application contracts. Source revisions identify evidence, not required
dependency versions.

Contents: [records and metadata](#records-and-metadata),
[owned indexes](#owned-indexes),
[text and partial application](#text-and-partial-application),
[diagnostics](#diagnostics), [exceptions](#exceptions),
[resource scope and macros](#resource-scope-and-macros), and
[module initialization](#module-initialization).

## Records and metadata

Haunt's
[post module](https://git.dthompson.us/haunt/tree/haunt/post.scm?id=a154de4a02cfb11c185a851170400ad83b1c914e)
combines a private SRFI-9 record type, public accessors, alist metadata, and
`filter-map` with `match` in `post-ref-all`. The example retains those choices,
but exposes only the constructor and operations needed by its callers. It
accepts arbitrary metadata values, including `#f`; it does not use the value
itself as a filter predicate.

Save this block as `example/entry.scm` when trying the subsequent examples:

```scheme
(define-module (example entry)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:export (make-entry entry-key entry-labels metadata-values))

(define-record-type <entry>
  (make-entry key metadata)
  entry?
  (key entry-key)
  (metadata entry-metadata))

(define (metadata-values metadata key)
  "Return values under symbol KEY in order, retaining false values.
The result has a fresh list spine; its values are borrowed from METADATA."
  (fold-right (lambda (field result)
                (match field
                  ((name . value)
                   (if (eq? name key) (cons value result) result))))
              '()
              metadata))

(define (entry-labels entry)
  "Return ENTRY's label strings in metadata order.
ENTRY and its metadata are treated as read-only; label values are borrowed."
  (metadata-values (entry-metadata entry) 'label))
```

The constructor assumes the caller provides valid fields and retains ownership
of the supplied metadata. No setters are generated, but nested lists and strings
still require the read-only convention. Use `entry-key` across the module
boundary; do not destructure its private record layout. Export neither `<entry>`
nor `entry?` just for symmetry.

This example separates `fold-right` from Haunt's filtering choice because
`filter-map` drops false results. It is suitable when false metadata is valid;
use `filter-map` directly when dropping false results is the intended contract.

## Owned indexes

Haunt's `posts/group-by-tag` builds a local native hash table and converts it to
an alist. Here the table and bucket spines belong to one call. The adaptation
preserves entry order within each label and sorts labels explicitly rather than
relying on hash-table traversal order.

```scheme
(use-modules (example entry)
             (srfi srfi-1))

(define (group-entries entries)
  "Group ENTRIES by label, sorting labels and preserving entry order.
Do not mutate ENTRIES. Return fresh index spines containing borrowed entries."
  (let ((index (make-hash-table)))
    (for-each
     (lambda (entry)
       (for-each
        (lambda (label)
          (hash-set! index label
                     (cons entry (hash-ref index label '()))))
        (delete-duplicates (entry-labels entry) string=?)))
     entries)
    (sort (hash-fold (lambda (label bucket result)
                       (acons label (reverse! bucket) result))
                     '()
                     index)
          (lambda (left right)
            (string<? (car left) (car right))))))
```

`hash-ref` and `hash-set!` use the same equality family. `reverse!` consumes a
locally built bucket and its returned value is used. Neither operation mutates
the input entries. To refresh an already published index, build another index
with this procedure and hand it to the project's existing publication mechanism.
This procedure does not define synchronization or transaction rules.

## Text and partial application

Haunt's `post-slug-v2` combines SRFI-13 string operations with SRFI-14 character
sets. This adaptation only makes a display label: it intentionally does not
define persistent identifiers, URL slugs, or Unicode normalization policy.

```scheme
(use-modules (srfi srfi-13)
             (srfi srfi-14)
             (srfi srfi-26))

(define (normalize-label text)
  "Collapse whitespace runs in TEXT to one space, preserving letter case.
Return display text; do not perform Unicode normalization or assign identity."
  (string-join
   (string-tokenize text (char-set-complement char-set:whitespace))
   " "))

(define (prefix-labels prefix labels)
  "Return LABELS with PREFIX prepended to each string."
  (map (cut string-append prefix <>) labels))

(define (make-labeler read-prefix)
  "Call READ-PREFIX now and retain its string for later label formatting."
  (cute string-append (read-prefix) <>))
```

Haunt's
[reader selection](https://git.dthompson.us/haunt/tree/haunt/reader.scm?id=a154de4a02cfb11c185a851170400ad83b1c914e)
uses `cut` for a short adapter; the `cute` example is a companion illustrating
the evaluation distinction, not a quotation from Haunt. Replace `cute` with
`cut` only if each invocation should call `read-prefix` again. When formatting
requires branching, name an ordinary procedure instead of nesting slot forms.

## Diagnostics

This example combines Haunt's record/alist style with the skill's agreed
diagnostic-return policy. The diagnostic shape and validation rule are local
teaching choices, not an upstream API or a new project-wide result framework.
The named loop keeps successful inputs and diagnostics in encounter order, using
SRFI-11 to bind the two results from each step.

```scheme
(use-modules (srfi srfi-9)
             (srfi srfi-11)
             (srfi srfi-13))

(define-record-type <diagnostic>
  (make-diagnostic source field code message)
  diagnostic?
  (source diagnostic-source)
  (field diagnostic-field)
  (code diagnostic-code)
  (message diagnostic-message))

(define (validate-heading source metadata)
  "Return METADATA and no diagnostics, or #f and a heading diagnostic.
SOURCE identifies the input. METADATA must be an alist; do not mutate it."
  (let ((heading (assq-ref metadata 'heading)))
    (if (and (string? heading)
             (not (string-null? (string-trim-both heading))))
        (values metadata '())
        (values #f
                (list (make-diagnostic source 'heading 'required
                                       "Expected a nonblank heading"))))))

(define (validate-inputs inputs)
  "Return valid metadata and accumulated diagnostics in input order.
INPUTS contains (source . metadata) pairs; both returned list spines are new."
  (let loop ((rest inputs) (valid '()) (diagnostics '()))
    (if (null? rest)
        (values (reverse valid) (reverse diagnostics))
        (let-values (((value issues)
                      (validate-heading (caar rest) (cdar rest))))
          (loop (cdr rest)
                (if value (cons value valid) valid)
                (append (reverse issues) diagnostics))))))
```

Invalid user content becomes data. A malformed internal `inputs` structure is a
programming error, not another missing-heading diagnostic. File access belongs
outside this transformation and retains its I/O exception behavior.

## Exceptions

Guix's
[error handling](https://codeberg.org/guix/guix/src/commit/0daef659a23220fa76a62dcbda7057cb649f415c/guix/ui.scm)
classifies failures before selecting a response. This new-code example uses
Guile's exception API, with an explicit unwinding recovery boundary. The
fallback is valid only where a caller has deliberately chosen it as policy.

```scheme
(use-modules (ice-9 exceptions))

(define-exception-type &backend-unavailable &external-error
  make-backend-unavailable backend-unavailable?
  (operation backend-unavailable-operation))

(define (call-with-backend-fallback thunk fallback)
  "Call THUNK; on backend unavailability, return FALLBACK's result.
FALLBACK receives the failed operation. Propagate all unrelated exceptions."
  (with-exception-handler
      (lambda (exception)
        (fallback (backend-unavailable-operation exception)))
    thunk
    #:unwind? #t
    #:unwind-for-type &backend-unavailable))

(call-with-backend-fallback
 (lambda () (raise-exception (make-backend-unavailable 'fetch)))
 (lambda (operation) (list 'unavailable operation)))
;; => (unavailable fetch)
```

The type filter selects the failures this boundary can recover from. Other
exceptions retain their original propagation path instead of being unwound and
raised again here. Check the
[Guile exception interface](https://www.gnu.org/software/guile/manual/html_node/Raising-and-Handling-Exceptions.html)
in the project's toolchain before adopting this keyword form. A returning
handler needs the explicit unwinding mode for a non-continuable exception.

For an existing keyed API, Guix's
[`false-if-file-not-found`](https://codeberg.org/guix/guix/src/commit/0daef659a23220fa76a62dcbda7057cb649f415c/guix/build/utils.scm)
demonstrates selecting one errno and propagating others. The adaptation uses a
procedure because the operation here needs no special evaluation syntax.

```scheme
(define (stat-or-false file)
  "Return FILE's stat data, or #f for ENOENT; propagate other failures."
  (catch 'system-error
    (lambda () (stat file))
    (lambda arguments
      (if (= ENOENT (system-error-errno arguments))
          #f
          (apply throw arguments)))))
```

Do not broaden this to `catch #t`. A missing optional file and a permission
failure are different outcomes. Use SRFI-34/35 only when integrating with that
existing condition interface; see
[the interoperability example](srfi-examples.md#existing-thread-and-condition-interfaces).

## Resource scope and macros

Guix's `with-directory-excursion` uses `dynamic-wind` around scoped state. The
following adaptation owns an input port instead; process-wide directory changes
would be inappropriate as per-request state in a concurrent server. The entry
check rejects a continuation that tries to resume after the owned port has been
closed, instead of resuming computation against that resource.

This example is for synchronous use without scheduler suspension. If a scope can
suspend in native Fibers, inspect that library's continuation and resource
contracts. Do not close a live port merely because a scheduler switch leaves the
dynamic extent. A synchronous CLI does not need a scheduler to use this example.

```scheme
(use-modules (ice-9 rdelim))

(define (call-with-owned-input file proc)
  "Call PROC with an owned input port for FILE; return its values.
Close the port on normal return or unwinding. PROC must not close or retain
the port or defer reading from it; reject reentry after the port is closed."
  (let ((port (open-input-file file)))
    (dynamic-wind
      (lambda ()
        (when (port-closed? port)
          (error "Cannot reenter a closed input scope" file)))
      (lambda () (proc port))
      (lambda () (close-port port)))))

(define-syntax-rule (with-owned-input (port file) body ...)
  (call-with-owned-input file (lambda (port) body ...)))
```

Prefer calling the procedure with a lambda. Add the optional macro only if this
binding form recurs often enough to help readers. It evaluates `file` once,
introduces no capturing temporary, and delegates cleanup to one procedure. A
direct use is `(with-owned-input (input path) (read-line input))` inside a
caller that already has `path`. Configure its indentation in the existing
formatter when adopting it, and check expansion and cleanup behavior.

Do not return a lazy stream reading this port after the scope ends. Either
consume it inside the scope or design a separate explicit resource owner. For
foreign buffers, likewise distinguish an owned copy that may escape from a
borrowed view whose lifetime ends with its owner.

## Module initialization

Haunt's
[command module](https://git.dthompson.us/haunt/tree/haunt/ui.scm?id=a154de4a02cfb11c185a851170400ad83b1c914e)
exports `haunt-main` and keeps command dispatch in an explicit entry procedure.
Use that separation when a module also needs to be loaded by tests or other
libraries: define the operation on import and start it through its caller. This
does not require copying Haunt's command layout or compatibility macros.

Use the module's public interface through normal imports. Guile's private lookup
forms are useful for focused debugging, but routine callers should not bypass
exports. Re-export a dependency only when it is intentionally part of your API.
Use `#:select`, prefixes, or renaming for actual ambiguity instead of turning
every import into a prescribed list.

A REPL session can conceal a missing import or phase dependency. Verify changed
modules in a fresh process using the project's source and compiled load paths.
Guile's `-L` and `-C` affect different search paths; auto-compilation can also
populate a cache. Follow the build rules for generated modules and `.go` files
rather than solving path errors by changing the working directory or writing
artifacts beside source files. See the
[Guile load-path reference](https://www.gnu.org/software/guile/manual/html_node/Load-Paths.html).
