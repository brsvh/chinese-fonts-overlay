# Reading configuration as data

Read for external configuration or site data that must not execute code. Follow
the application's chosen format, schema, and path policy; this reference does
not introduce configuration keys, defaults, or an instance layout.

## Separate reading, validation, and activation

Read input into data, validate its structure and values, then activate the
validated configuration. Do not start a listener or publish partially validated
state while still discovering configuration errors. Resolve defaults
deliberately; an explicitly invalid value is not the same as an omitted value.

For a Scheme datum format, use the intended reader rather than `load`,
`primitive-load`, or `eval`. Reading `(some-procedure ...)` produces a list;
evaluating or loading it can invoke code. Guile also permits reader extensions
through `read-hash-extend`: a data reader should not acquire application plugins
or effectful read handlers incidentally. Ordinary `read` plus validation is not
a general sandbox for arbitrary hostile input. Keep its accepted syntax and
resource limits appropriate to the actual input boundary.

Haunt and Shepherd deliberately load executable Scheme configurations. Their
configuration loaders are examples of a different contract, not recipes for
reading an inert instance-data file.

## Shepherd: read a protocol datum without evaluating it

[Shepherd 40edccbf `comm.scm`](https://codeberg.org/shepherd/shepherd/src/commit/40edccbf04710913a811dfd5710afd9cb9ca808f/modules/shepherd/comm.scm)
provides an actual inert-data example in `read-command`. It reads a datum,
handles decoding/read failures, matches the tagged command structure and
supported version, then constructs a command record. It does not evaluate the
received list. `write-command` emits the corresponding tagged datum and flushes
the port; both directions define the protocol shape.

This is a command protocol, not Shepherd's executable configuration loader. Its
match checks exact field structure and a version beginning with zero; it is not
a general schema validator for every value. Its false return combines EOF,
malformed input, and unsupported data because that is this reader's interface.
Its one-command read also does not establish EOF for an entire file.

For an instance-data reader, retain the read/validate/construct separation but
choose the file's own schema, value checks, duplicate policy, and diagnostics. A
single-document file needs the extra EOF check below. Do not copy the command
protocol's field names, false-on-every-failure result, or version negotiation
into a new configuration format. The example below is an adaptation of the
boundary, not an extracted Shepherd loader.

## Establish the document contract

Specify the encoding, whether empty input is valid, and whether one document or
several are permitted. For a single-datum format, read again to verify EOF;
silently ignoring a second expression can conceal an edited or malformed file.
Comments and whitespace after the datum are not additional data.

This borrowed-port example separates document-shape errors from schema checks.
Its diagnostic lists are illustrative, not a new project-wide result protocol:

```scheme
(define (read-one-datum port source)
  "Read one datum from borrowed PORT, returning data and diagnostics.
SOURCE identifies the input. Preserve I/O exceptions; do not close PORT.
A false datum is valid at this layer when diagnostics are empty."
  (catch 'read-error
    (lambda ()
      (let ((datum (read port)))
        (cond
         ((eof-object? datum)
          (values #f (list (list 'empty-input source))))
         ((not (eof-object? (read port)))
          (values #f (list (list 'extra-datum source))))
         (else
          (values datum '())))))
    (lambda (key . arguments)
      (values #f (list (list 'invalid-syntax source key arguments))))))
```

The file-owning caller opens with the chosen encoding and closes its port on
success and failure. Keep syntax-error context, including available filename,
line, and column information. Catch the reader's documented error category
deliberately; do not catch every exception and describe disk or permission
failures as invalid syntax.

Validate collection shape before field lookup: an alist reader must check proper
list structure, entry shape, key type, and value type. Choose duplicate-key and
unknown-key behavior explicitly instead of inheriting the first-match behavior
of `assq-ref`. Check missing and false values separately when false is
meaningful. Accumulate independent field diagnostics where useful, but stop
traversing a structure whose shape is invalid.

## Paths and startup failures

Keep the original filename or other source identifier with diagnostics. For
relative paths, choose a documented base, such as the configuration file's
directory or an explicit invocation base. Resolve once and retain that meaning
after startup; do not make later behavior depend on a changed working directory.
Do not silently substitute another directory or instance when access fails.

Keep path normalization separate from existence and access checks. A successful
earlier check does not guarantee that a later open succeeds. Catch the actual
I/O failure at the owning operation and retain useful context. Resolve symlinks
only according to the application's resource policy, not as an incidental side
effect of string normalization.

At the command boundary, report expected configuration failures and stop with a
nonzero exit status before announcing readiness. Library readers return
diagnostics or raise the appropriate exception; they do not terminate the
process. If startup has already acquired resources, release those owned by the
failed attempt. Avoid turning an exception into an apparently valid default
configuration.

## Focused verification

Exercise valid input, an empty file, a second datum, malformed syntax, duplicate
and unknown fields under the chosen policy, and a false value where allowed.
Check one actual I/O failure separately from schema failures. Change the
caller's working directory to verify the documented relative-path behavior.
Where the data/code distinction is in doubt, read a procedure-shaped datum and
demonstrate that the reader does not evaluate it; schema validation should then
decide whether that shape is permitted.

## Source basis

- [Guile 3.0.11 reader](https://codeberg.org/guile/guile/src/tag/v3.0.11/libguile/read.c)
  and `doc/ref/api-evaluation.texi` establish `read`, reader errors, reader
  options, and hash-reader extensions. Port ownership follows the native Guile
  resource contract.
- [Haunt configuration loading at a154de4a](https://git.dthompson.us/haunt/tree/haunt/ui.scm?id=a154de4a02cfb11c185a851170400ad83b1c914e)
  calls `load`;
  [Shepherd at 40edccbf](https://codeberg.org/shepherd/shepherd/src/commit/40edccbf04710913a811dfd5710afd9cb9ca808f/modules/shepherd/service.scm)
  uses `load-in-user-module`. Both are intentionally executable configuration
  models. The data-only workflow and example above are adaptations for a
  different application requirement.
