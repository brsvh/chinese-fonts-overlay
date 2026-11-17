# Conditional SRFI Examples

Use a section only when its scenario applies. The common SRFIs 1, 9, 11, 13, 14,
and 26 appear in [native examples](native-examples.md); SRFI-64 appears in
[verification examples](verification-examples.md). These examples supplement the
selection rules in [SRFI policy](srfi-policy.md), not the default imports.

Contents: [dependent bindings](#dependent-bindings),
[vector representations](#vector-representations),
[time and random sources](#time-and-random-sources),
[command-line parsing](#command-line-parsing),
[streams and table semantics](#streams-and-table-semantics),
[comprehensions and bindings](#comprehensions-and-bindings), and
[existing interfaces](#existing-thread-and-condition-interfaces).

The application sources below demonstrate practical use. For less common
facilities, examples draw on the corresponding tests in the
[Guile source release](https://ftp.gnu.org/gnu/guile/guile-3.0.11.tar.xz), under
`test-suite/tests/`. The cited release identifies inspected source, not a
runtime requirement. Snippets use new inputs and simplified purposes; they are
not transcriptions of the test suite or evidence of Hoot support.

## Dependent bindings

Guile's `srfi-2.test` exercises short-circuiting dependent bindings. This is a
good fit when `#f` fully describes an unsuccessful conversion; it is a poor fit
when callers need several validation diagnostics.

```scheme
(use-modules (srfi srfi-2))

(define (positive-count text)
  "Return an exact positive integer parsed from TEXT, or #f."
  (and-let* (((string? text))
             (number (string->number text))
             ((exact-integer? number))
             ((positive? number)))
    number))

(positive-count "12") ; => 12
(positive-count "-1") ; => #f
```

SRFI-8 can keep a single binding compact in code already using `receive`.
Guile's
[SRFI-8 documentation](https://www.gnu.org/software/guile/manual/html_node/SRFI_002d8.html)
is the source for this syntax; it is not a community project preference over
SRFI-11. Prefer the latter in new code unless the local context favors this:

```scheme
(use-modules (srfi srfi-8))

(receive (whole remainder) (floor/ 17 5)
  (list whole remainder))
;; => (3 2)
```

## Vector representations

Guile's `srfi-4.test` covers homogeneous numeric vectors. Choose one because the
representation matters, not merely because the elements happen to be numbers.
This example represents three unsigned octets; it does not prescribe an FFI
layout, byte order, or text encoding.

```scheme
(use-modules (srfi srfi-4))

(let ((octets (u8vector 16 32 255)))
  (u8vector->list octets))
;; => (16 32 255)
```

In guile-json's
[`json-build-array`](https://github.com/aconchillo/guile-json/blob/71e67e7a06bfd0c334ead311b53fefb92b965124/json/builder.scm),
SRFI-43 supplies an index to the callback for delimiter handling. Here that
indexed callback instead produces numbered values, as in Guile's `srfi-43.test`.
A prefix makes the SRFI-specific callback signature visible.

```scheme
(use-modules ((srfi srfi-43) #:prefix vector:))

(vector:vector-map (lambda (index label)
                     (cons (+ index 1) label))
                   '#("alpha" "beta"))
;; => #((1 . "alpha") (2 . "beta"))
```

Do not substitute another `vector-map` without checking its callback arity.

## Time and random sources

Shepherd's
[timer module](https://codeberg.org/shepherd/shepherd/src/commit/40edccbf04710913a811dfd5710afd9cb9ca808f/modules/shepherd/service/timer.scm)
uses SRFI-19 for calendar computations. This smaller example formats supplied
UTC seconds, following the explicit time conversions in Guile's `srfi-19.test`.
No clock lookup is hidden inside the transformation.

```scheme
(use-modules ((srfi srfi-19) #:prefix time:))

(define (utc-date-text seconds)
  "Format exact UTC SECONDS since the epoch as a date at offset zero."
  (time:date->string
   (time:time-utc->date (time:make-time time:time-utc 0 seconds) 0)
   "~Y-~m-~d"))

(utc-date-text 0) ; => "1970-01-01"
```

Guile's `srfi-27.test` checks reseeding behavior. Use a source owned by the
fixture or simulation, rather than changing `default-random-source` globally.
Repeatability here is scoped to the implementation, not a promise of identical
sequences across unrelated runtimes. This is not a source for secret tokens.

```scheme
(use-modules (srfi srfi-27))

(define (make-sample-picker stream-id)
  "Return an owned, repeatable integer sampler for non-secret test data.
STREAM-ID is a nonnegative exact integer; each call advances the source."
  (let ((source (make-random-source)))
    (random-source-pseudo-randomize! source stream-id 0)
    (random-source-make-integers source)))

(let ((left (make-sample-picker 7))
      (right (make-sample-picker 7)))
  (= (left 100) (right 100)))
;; => #t
```

## Command-line parsing

Haunt's
[`simple-args-fold`](https://git.dthompson.us/haunt/tree/haunt/ui.scm?id=a154de4a02cfb11c185a851170400ad83b1c914e)
accumulates options with SRFI-37. This adaptation returns unknown-option names
instead of exiting from the callback. A caller can render those diagnostics and
decide its exit status. Operands after `--` remain operands.

```scheme
(use-modules (srfi srfi-11)
             (srfi srfi-37))

(define (parse-arguments arguments)
  "Return a verbose flag, operand strings, and unknown-option names.
Keep operands and unknown names in encounter order; do not exit or print."
  (let-values
      (((verbose files unknown)
        (args-fold
         arguments
         (list (option '(#\v "verbose") #f #f
                       (lambda (option name argument verbose files unknown)
                         (values #t files unknown))))
         (lambda (option name argument verbose files unknown)
           (values verbose files (cons name unknown)))
         (lambda (operand verbose files unknown)
           (values verbose (cons operand files) unknown))
         #f '() '())))
    (values verbose (reverse files) (reverse unknown))))

(call-with-values
    (lambda () (parse-arguments '("-v" "--bad" "--" "-draft")))
  list)
;; => (#t ("-draft") ("bad"))
```

## Streams and table semantics

Guile's `srfi-41.test` combines `stream-from`, `stream-map`, and bounded
consumption. Here a finite prefix is produced without materializing an unbounded
sequence. All delayed work is pure: there is no captured port that could already
have been closed.

```scheme
(use-modules (srfi srfi-41))

(stream->list 4 (stream-map (lambda (n) (* n n)) (stream-from 1)))
;; => (1 4 9 16)
```

Guile's `srfi-69.test` checks case-insensitive tables. Binding equality and a
consistent hash function to the object is the concrete benefit here. The prefix
distinguishes these operations from native Guile tables.

```scheme
(use-modules ((srfi srfi-69) #:prefix table:))

(let ((counts (table:make-hash-table string-ci=? table:string-ci-hash)))
  (table:hash-table-set! counts "Scheme" 2)
  (table:hash-table-ref counts "SCHEME"))
;; => 2
```

This is a lookup example, not a rule that all application keys ignore case.

## Comprehensions and bindings

Guile's `srfi-42.test` demonstrates filtered comprehensions. A small Cartesian
product can be clearer than nested accumulation; a simple one-list map usually
does not need this syntax.

```scheme
(use-modules (srfi srfi-42))

(list-ec (:range row 1 4) (:range column 1 4)
         (if (< row column)) (list row column))
;; => ((1 2) (1 3) (2 3))
```

Shepherd's timer parser mixes ordinary and multiple-value bindings with SRFI-71.
The following adaptation places one count beside quotient/remainder bindings; a
prefix avoids replacing all ordinary `let` forms in the example.

```scheme
(use-modules ((srfi srfi-71) #:prefix extended:))

(extended:let ((page-size 5)
               (whole remainder (floor/ 17 5)))
              (list whole remainder page-size))
;; => (3 2 5)
```

Guile's `srfi-197.sr64` tests chains with the placeholder in different argument
positions. This native example reads naturally as split, trim, then remove empty
fields; keep a simple named call when a pipeline would obscure meaning.

```scheme
(use-modules (srfi srfi-1)
             (srfi srfi-13)
             (srfi srfi-197))

(chain " alpha, ,beta "
       (string-split _ #\,)
       (map string-trim-both _)
       (remove string-null? _))
;; => ("alpha" "beta")
```

## Existing thread and condition interfaces

Guile's `srfi-18.test` checks starting and joining owned threads. This compact
example is relevant when the surrounding component already uses SRFI-18. It does
not propose an additional scheduler for server code using another model.

```scheme
(use-modules ((srfi srfi-18) #:prefix thread:))

(let ((worker (thread:make-thread (lambda () (* 6 7)))))
  (thread:thread-start! worker)
  (thread:thread-join! worker))
;; => 42
```

Shepherd's
[service conditions and guards](https://codeberg.org/shepherd/shepherd/src/commit/40edccbf04710913a811dfd5710afd9cb9ca808f/modules/shepherd/service.scm)
show typed SRFI-35 failures with targeted SRFI-34 handling. This miniature
dependency stand-in illustrates an existing missing-value condition. The guard
only handles that type; other conditions propagate automatically.

```scheme
(use-modules ((srfi srfi-34) #:prefix legacy:)
             ((srfi srfi-35) #:prefix legacy:))

(legacy:define-condition-type &legacy-missing legacy:&condition
                              legacy-missing?
                              (key legacy-missing-key))

(legacy:guard (failure
               ((legacy-missing? failure) #f))
              (legacy:raise (legacy:condition (&legacy-missing (key "absent")))))
;; => #f
```

Do not introduce this condition API solely to copy the example into new code.
Use the main skill's Guile exception convention there. Likewise, SRFI-105 and
SRFI-119 deliberately have no adoption examples: all authored examples use the
chosen ordinary parenthesized syntax.
