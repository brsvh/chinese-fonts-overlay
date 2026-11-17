# SRFI Policy

Use this reference when selecting or changing a SRFI dependency or an
overlapping Guile interface. These are library-selection defaults, not a
portability target or a closed whitelist. Existing project contracts take
precedence.

For code illustrating these choices, use [native examples](native-examples.md)
for the common data SRFIs, [conditional examples](srfi-examples.md) for the
optional set, and [verification examples](verification-examples.md) for SRFI-64.
Example availability does not change the admission criteria below.

## Admission criteria

Choose by semantic fit, readability, existing ecosystem use, and verified target
support. Prefer suitable Guile-bundled implementations; declare external
dependencies when they provide a concrete benefit. For a SRFI outside the common
recommendations, explain the need in the change's normal review context rather
than creating a separate approval process.

Check the implementation and specific exported procedures or syntax used. A
finalized SRFI is not proof of availability or complete implementation in the
selected Guile environment. Do not label a SRFI obsolete simply because a
related newer SRFI exists, or introduce a newer one solely to modernize syntax.

## Common native Guile recommendations

Use these when they fit the task; do not import all of them into every module.

| SRFI | Role                    | Convention                                                                                                                                                 |
| ---- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | List operations         | Prefer direct operations for filtering, searching, and folding when clearer than a custom traversal. Apply the ownership rule to linear-update operations. |
| 9    | Records                 | Default for stable data structures. Keep type descriptors and mutators private unless they are part of an intentional public interface.                    |
| 11   | Multiple-value bindings | Prefer `let-values` and `let*-values` for explicit multiple-value binding.                                                                                 |
| 13   | Strings                 | Reuse suitable string operations. Preserve the intended Unicode, indexing, and normalization semantics.                                                    |
| 14   | Character sets          | Express character classification and set operations explicitly. Verify the character ranges required by the application.                                   |
| 26   | Partial application     | Use `cut` for simple argument placement; use `cute` only for intentional evaluation at procedure creation.                                                 |
| 64   | Testing                 | Default for native Guile test organization and reporting, not an application runtime dependency.                                                           |

SRFI-1 linear-update procedures may reuse or mutate input storage; they do not
promise to mutate a particular object. Use their returned result and pass only
data whose ownership permits the operation. Do not apply them to a published
read-only version or input shared with other readers.

For SRFI-26, non-slot expressions in `cut` are evaluated on each invocation;
`cute` evaluates them when creating the procedure. Choose by the intended
evaluation behavior, not by assuming the forms are interchangeable.

## Use when the task warrants it

| SRFI        | Appropriate use and constraints                                                                                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 2           | Use `and-let*` for a clear sequence of dependent bindings and checks. Prefer ordinary bindings and conditionals when the failure path needs explanation or diagnostics.                                      |
| 8           | `receive` is available for a single multiple-value binding. Keep SRFI-11 as the default instead of mixing equivalent forms without a readability benefit.                                                    |
| 4, 43       | Use specialized numeric vectors or generic vector operations when the data representation requires them. Verify FFI representation and API semantics where relevant.                                         |
| 19          | Use date and time operations with explicit units and time representations. Disambiguate bindings such as `current-time` when they overlap with Guile interfaces.                                             |
| 27          | Use random sources for tests, simulation, or other suitable non-secret data. Do not infer cryptographic suitability from the SRFI interface; security-sensitive tokens need a verified cryptographic source. |
| 37          | Use for command-line parsing when its argument-folding interface fits the command structure. Existing Guile parsers remain valid choices.                                                                    |
| 41          | Use lazy streams for a concrete benefit. Define port and resource lifetimes, and avoid unintentionally retaining old data versions through delayed computations.                                             |
| 69          | Use when table-bound equality and hashing or integration with another API is beneficial. Native Guile hash-table interfaces remain the server default.                                                       |
| 42, 71, 197 | Allow comprehensions, extended bindings, or chaining when they make the actual code clearer. Verify target support and avoid mechanical rewrites just to adopt the syntax.                                   |

For SRFI-18, follow the project's existing concurrency model and integration
requirements. Its standard status alone is not a reason to introduce another
threading interface or replace an established scheduler.

SRFI-34 and SRFI-35 remain available for exception and condition
interoperability. For new exception handling, follow the main skill's Guile
exception convention. Do not reject established dependency APIs merely because
they use these SRFIs.

## Source syntax exclusions

Do not use SRFI-105 or SRFI-119 in authored source. Ordinary parenthesized
Scheme is the source convention, keeping editing, formatting, and review
consistent. This is a project style choice, not a claim that those SRFIs are
invalid.

## Shared modules

These defaults describe native Guile. For a module also compiled with Hoot,
apply `hoot-coding` and check the specific imports, macro expansion, and
executed behavior there. Native library availability does not prove support on
another target or require restricting unrelated server code.

## Primary references

- [Guile reference manual](https://www.gnu.org/software/guile/manual/): Guile
  interfaces, SRFI implementations, module imports, and exception semantics.
- [SRFI index](https://srfi.schemers.org/): specification status and the exact
  semantics of each SRFI.
- [SRFI-1 specification](https://srfi.schemers.org/srfi-1/srfi-1.html):
  linear-update semantics and list operations.
- [SRFI-26 specification](https://srfi.schemers.org/srfi-26/srfi-26.html):
  partial application and evaluation timing.
