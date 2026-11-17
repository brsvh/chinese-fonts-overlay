---
name: guile-coding
description: >-
  Write, review, and refactor GNU Guile Scheme with explicit module
  interfaces, idiomatic data handling, deliberate SRFI choices, and focused
  verification. Use for native Guile modules, libraries, server code, scripts,
  macros, resource handling, test drivers, and Guile-based build and
  maintenance commands. Use guile-web-coding for HTTP and server-rendered
  HTML, and hoot-coding for Scheme compiled with Hoot; shared modules may need
  both native and Hoot guidance.
---

# Guile Coding

Apply this skill to native Guile code. Read the target project's applicable
`AGENTS.md`, module layout, and build instructions; this skill does not select
its architecture, directory names, UI language, or publication policy.

Resolve bundled references relative to this skill's installed directory, not the
target checkout. Obtain commands and dependencies from the target's actual
environment. Do not assume a Nix devshell, an existing compiler cache, or a
previous session's temporary files. Discover companion skills by name when
available; their installation need not be adjacent to this skill.

Obtain dependency versions and available check commands from the repository and
actual tools. A target described in a plan is not evidence that it already
works. The community examples below illustrate mechanisms; their directories,
dependencies, and application policies are not templates for the target project.

Read concrete community-derived examples only for the relevant work:

- [Application patterns](references/application-patterns.md): organizing a new
  feature, ordered adapters, deferred effects, and the tradeoffs behind Haunt.
- [Native examples](references/native-examples.md): module interfaces, records,
  metadata, owned mutation, text, diagnostics, exceptions, resource scope, and
  explicit startup.
- [Conditional SRFI examples](references/srfi-examples.md): specific reasons to
  use the optional facilities in the SRFI policy and their API pitfalls.
- [Configuration data](references/configuration-data.md): read only when reading
  external configuration or data, validating its shape, or reporting startup
  failures.
- [Verification examples](references/verification-examples.md): meaningful
  regressions, test-runner exit status, and deliberate interface changes.

The examples identify inspected community sources and explain adaptations. Treat
their sample data and interfaces as teaching choices, not project design
requirements or templates to import wholesale.

For native HTTP handlers, URI handling, public-resource serving, or SXML/HTML
rendering, also use `guile-web-coding` if available. Load its Web references
only for that work; ordinary Scheme edits do not require them.

## Native execution and shared code

Use Guile-specific facilities and its library ecosystem when they fit native
code. The Hoot compiler and a test driver can themselves run in native Guile;
that does not make their dependencies available inside compiled Wasm.

Share modules when actual callers need the same contract. For modules also
compiled with Hoot, verify the shared imports and behavior on both targets, and
apply `hoot-coding` to their compiled use. Keep native-only server code free to
use suitable Guile facilities.

## Libraries and modules

Prefer suitable libraries bundled with Guile. Add external dependencies when
their concrete benefit justifies them, and declare them through the project's
existing dependency mechanism.

When selecting or changing SRFI usage, read
[SRFI policy](references/srfi-policy.md). The recommendations are an open set,
not a whitelist. Explain the benefit of additions outside the recommended set
and verify the particular interfaces used on their execution targets.

Whole-module imports are allowed. Use `#:select`, renaming, or prefixes when
bindings conflict or their meaning would otherwise be ambiguous. Inspect
neighboring modules for the established module path and naming conventions.

Use declared imports for library dependencies. Keep loading a reusable module
separate from starting services, reading live instance configuration, changing
the process directory, or launching background work. Expose those effects
through explicit entry procedures. Macros that need compile-time helpers must
make their phase requirements explicit; successful interactive evaluation is not
evidence that a fresh compilation will work.

Export only interfaces intended for callers. Keep internal helpers, record type
descriptors, and mutators private by default. Export a type descriptor or
mutator when a concrete public contract requires it; constructors, predicates,
and accessors do not all need to be public automatically.

For an interface change within the authorized scope, honor explicit existing
compatibility commitments. Otherwise update the interface, relevant callers, and
tests together. Do not invent compatibility obligations, preserve obsolete call
forms merely to satisfy old tests, or add unneeded compatibility shims and
compatibility tests.

## Data and effects

- Prefer SRFI-9 records for objects with stable fields. Use alists for open
  metadata and small local mappings. Follow public accessors across module
  boundaries instead of depending on private record layouts.
- On the server, default to Guile's native hash-table interfaces. Keep equality
  and hashing consistent for a given table. Use SRFI-69 when binding these rules
  to the table object or integrating with another API provides a clear benefit.
  Do not rely on unspecified hash-table traversal order.
- Default to treating data as read-only. Local mutation is appropriate while
  constructing data the code owns, such as an index. Respect ownership when
  mutating arguments, and do not mutate a published version shared with readers.
  Build a replacement and publish it through the existing project mechanism.
- Separate data transformations from file access, current-time lookup, and other
  host effects when practical. Make instance state and resource ownership
  explicit instead of relying on a mutable global current instance.
- Keep ports, foreign resources, and host callbacks within documented lifetimes.
  Specify cleanup and ownership at boundaries, including whether returned values
  remain valid after their backing resource is released.

## Existing concurrency and native boundaries

Follow the application's existing concurrency and resource-ownership contracts.
A static preview server does not by itself justify adding Fibers or a new
scheduler. Bound concurrent subprocesses and collect their failures before
publishing results. If native Fibers is actually used, consult the selected
library's suspension and resource-lifetime contract; synchronous `dynamic-wind`
examples are not a complete scheduler cleanup policy. Hoot asynchronous code
needs target-specific guidance such as `hoot-coding`, when available.

For Guile's native FFI, document the C signature, encoding, resource owner, and
callback lifetime. When C retains an address into Scheme-owned storage or a
callback, maintain the required owner lifetime explicitly. Use the existing
bridge contract for Rust or C resources; Hoot's host FFI has a different
representation and execution model.

## Expression style

- Use ordinary parenthesized Scheme. Do not use SRFI-105 curly-infix syntax or
  SRFI-119 Wisp syntax.
- Prefer `match` when destructuring nested lists, SXML, or structured messages.
  Use accessors for simple field reads and respect module abstraction
  boundaries.
- Prefer SRFI-11 `let-values` and `let*-values` for multiple-value bindings.
  SRFI-71 is available when its extended bindings materially improve
  readability.
- Allow SRFI-26 `cut` for simple partial application. Use a named procedure or
  `lambda` for branching, multiple steps, or complicated argument relationships.
  Use `cute` only when evaluating and retaining non-slot expressions at
  procedure creation is intentional.
- Choose list operations that express the task directly. Use a named loop when
  it makes state or control flow clearer; do not force every traversal into a
  fold or a chain of intermediate collections.
- Prefer ordinary procedures to macros. Introduce a macro for needed binding or
  evaluation semantics, or a stable repeated syntactic structure. Do not
  preemptively build a domain-specific language. Preserve hygiene and verify
  expansion on every target where the macro is used.

## Documentation and formatting

Use English for identifiers, code comments, and procedure docstrings, except
where an external interface requires another spelling. Preserve the language of
the product and existing documentation, including localized labels and sample
data. Keep machine-readable keys stable; do not translate names, quoted license
text, or upstream notices merely to satisfy a coding convention. Follow the
existing CLI diagnostic language and explicit user instructions.

Every handwritten top-level procedure must have an English docstring, including
private helpers. State what the procedure does; document non-obvious arguments,
results, units, ownership, side effects, and errors. In particular, distinguish
byte offsets from character positions and borrowed values from owned values.
Keep simple docstrings short. Generated procedures do not require handwritten
wrappers merely to attach docstrings.

Follow the repository's Scheme formatter and editor settings. Use syntax-aware
indentation with spaces, and keep closing parentheses with the final expression.
Wrap at complete expression or binding boundaries without altering string
literals, quoted data, or intentional layout. Give new macros indentation
support when required by the existing tooling.

## Errors and diagnostics

Return structured diagnostics for expected content-validation failures so that
callers can report multiple problems together. Use the project's result shape;
do not introduce a new result framework for each validator. Preserve useful
source and operation context.

Use exceptions for I/O failures and programming errors. New exception code
should prefer Guile's `raise-exception` and `with-exception-handler`. Use
targeted `catch` handlers to integrate with APIs that already signal keyed
exceptions. Do not mechanically rewrite working exception code just to normalize
its API.

Handle only failures for which the current boundary has a recovery policy.
Respect non-continuable exception semantics: when recovery requires unwinding,
use the appropriate unwinding form supported by the target, rather than
returning from a non-continuable handler and expecting normal execution to
resume. Do not silently turn unexpected failures into empty or successful
results.

## Verification

Use SRFI-64 as the default native Guile test framework. Keep independent
components on their appropriate existing test frameworks. A native test driver
may also orchestrate compiled code; its test framework need not be a dependency
of the program under test.

For behavior changes, bug fixes, and public-contract changes, add or update
focused automated checks when existing coverage is insufficient. Reuse adequate
tests; do not increase test count as an end in itself. Prefer a minimal
regression that exposes the original defect. Do not mechanically test trivial
accessors, pass-through wrappers, comments, or formatting. Assert observable
behavior and contracts instead of private helper decomposition, incidental call
counts, or internal representation. Update or remove obsolete tests after an
authorized interface change. If automation is impractical, explain why and
record the substitute verification.

Select checks according to the change and the project's requirements:

- Run relevant formatting checks and compile changed Scheme code using the
  project environment. Enable supported checks for unbound variables, arity
  mismatches, format-string mistakes, and other established warning categories.
  Fix warnings introduced by the change; explain necessary exceptions and report
  pre-existing warnings separately. Do not enable every possible warning as a
  universal fatal gate.
- Execute the affected tests. Ensure the overall check command reports failure
  when unexpected test failures occur; successful loading or compilation alone
  does not establish behavioral correctness.
- For shared modules, compile and execute the relevant behavior in both native
  Guile and their other declared targets. Reuse input cases and compare outcomes
  where the contract is shared, including Unicode and error cases.
- Add targeted integration checks when changes cross resource, update, or plugin
  boundaries. For a native bridge, exercise ownership and failure paths through
  the real boundary where practical.
- Use focused checks during local development and the full project-defined
  checks for CI and release work. Once relevant checks pass, broaden or repeat
  them only when requirements or unresolved concerns justify it.

Report what ran, its result, and what could not run. Limit compatibility claims
to the targets and behaviors actually verified.
