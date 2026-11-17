# Verification Examples

Read this page when choosing assertions, changing an interface, or connecting a
test command to compilation and execution. Examples draw on Hoot's
[`test-end*` and native SRFI-64 driver](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/test/utils.scm).
The source revision is provenance, not a toolchain requirement.

## A small regression with a reliable exit status

For the module in [native examples](native-examples.md#records-and-metadata),
this regression checks a specific failure mode: filtering metadata must not
silently discard a valid false value. It exercises the public operation rather
than adding a test for every generated record accessor.

Save as `check-entry.scm` alongside the `example` directory:

```scheme
(use-modules (example entry)
             (srfi srfi-64))

(test-begin "entry-metadata")
(let ((runner (test-runner-current)))
  (test-equal "Retain false values and duplicate-key order"
    '(#f "visible")
    (metadata-values '((flag . #f)
                       (label . "Scheme")
                       (flag . "visible"))
                     'flag))
  (test-end "entry-metadata")
  (exit (if (and (zero? (test-runner-fail-count runner))
                 (zero? (test-runner-xpass-count runner)))
            0
            1)))
```

Retain the runner before `test-end` clears the current runner. As in Hoot's
driver, both unexpected failures and unexpected passes affect the exit status.
When integrating with an existing runner, use its mechanism rather than adding
another runner to the project. Check the failure path once when introducing a
runner: deliberately break an expected result in a temporary copy and verify
that the command exits unsuccessfully.

## Match checks to behavior

The following are candidate assertions for the example behaviors, not a
mandatory test checklist or a request to create one test per row. Reuse an
existing test when it already protects the contract.

| Change             | Useful evidence                                                                            | Avoid                                                       |
| ------------------ | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------- |
| Label grouping     | An input with repeated labels preserves encounter order and is unchanged after grouping.   | Exact hash-bucket layout or helper-call counts.             |
| Text handling      | A required non-ASCII input preserves characters; character limits differ from byte counts. | Claiming all Unicode behavior from an ASCII fixture.        |
| Batch validation   | Two invalid inputs produce two contextual diagnostics while a valid input survives.        | One test for every diagnostic accessor.                     |
| Scoped resource    | A callback failure propagates and the captured test port is closed after unwinding.        | Checking only normal return or a mocked close-call count.   |
| Exception boundary | The intended failure takes its recovery path; an unrelated failure propagates.             | Catching every exception to make the test pass.             |
| Binding macro      | The file expression runs once and a caller's similarly named variable is not captured.     | Asserting a particular compiler-generated expansion string. |
| Shared module      | The same relevant inputs and failures execute on every declared target.                    | Counting successful compilation as execution.               |
| Concurrent work    | The owning operation observes completion or failure; unrelated work still makes progress.  | Assuming scheduler shutdown joins every spawned task.       |

## Interface changes without invented compatibility

Suppose an authorized change replaces the positional call
`(load-fragment source #t)` with `(load-fragment source #:strict? #t)` and there
is no commitment to preserve the positional form. Update the definition,
callers, examples, and behavior tests together. Keep a test proving what strict
mode rejects; remove the obsolete positional-call fixture. Do not add a
dispatcher accepting both forms or a test requiring the removed form merely
because it used to exist. This is an example of the project's chosen policy, not
a claim about an upstream project's compatibility promises.

If the real interface has an explicit compatibility promise, test that promised
behavior at its public boundary. Such a promise may be about stored data, a
plugin protocol, or an external API; it need not cover every private helper
signature.

## Compilation and reporting

Use the project's configured compiler invocation. For example, after checking
`guild compile --help` and supported warnings, a native module can be compiled
to a scratch output with checks for unbound names, arity, and format arguments:

```sh
guild compile -L . -W unbound-variable -W arity-mismatch \
  -W format -o entry.go example/entry.scm
guile --no-auto-compile -L . check-entry.scm
```

Apply the repository formatter to source examples when adopting them. External
libraries in a copied example must enter the project's real dependency
mechanism; `use-modules` alone does not declare a deployment dependency.

A useful report names the changed behavior, checks executed and results,
warnings introduced or already present, and checks that could not run. For
example: "The metadata regression passed and native compilation produced no new
warnings. Verification covered native Guile only." Report actual results rather
than copying this illustrative sentence.
