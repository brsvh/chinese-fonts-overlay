---
name: hoot-coding
description: >-
  Write, review, and refactor Scheme compiled with Guile Hoot, including
  browser interactions, Wasm host bindings, callbacks, asynchronous work, and
  modules shared with native Guile. Use for Hoot target code and its loading
  and reflection contracts; use guile-coding for native Guile code such as
  compiler-side helpers and test drivers.
---

# Hoot Coding

Apply these conventions to Scheme compiled with Hoot. Read the target project's
applicable `AGENTS.md`, source layout, and build instructions. Read
[browser interactions](references/site-browser.md) when changing filters, URL
state, asynchronous previews, or fallback behavior. Native build scripts and
tests may also use `guile-coding` when that skill is available.

Resolve bundled references, examples, and scripts relative to this skill's
installed directory, not the application checkout. Discover companion skills
through the session catalog instead of assuming adjacent installations. Use the
target's declared toolchain and available host; do not assume a Nix
installation, a specific browser automation API, or retained scratch files.

Use the repository's selected toolchain and actual build targets. Example paths
are scratch fixtures; historical validation versions are not dependency pins.

Read only the relevant reference:

- [Interaction state](references/interaction-state.md): session/action failure
  boundaries, repeated actions, and disposal, with REPL and browser source
  cases.
- [Host examples](references/host-examples.md): a shared transformation,
  explicit initialization, a disposable browser callback, and asynchronous
  reflection with success and failure results.
- [Host Promises](references/host-promises.md): awaiting an external Promise in
  Scheme and forwarding fulfillment, rejection, and synchronous host errors.
- [Verification examples](references/verification-examples.md): dual-target
  execution, compilation into a selected output directory, import contracts, and
  a retained probe for current-runtime browser behavior.

Examples adapt inspected Hoot community sources and public API documentation.
They teach mechanisms, not business rules, a component framework, or an
application template. Source revisions identify evidence, not dependencies.

## Execution and library boundaries

Distinguish three contexts: the native Guile compiler or test driver, compiled
Scheme, and the Wasm host. A native dependency of the compiler is not evidence
that compiled code can import it. Inspect the actual target libraries and
compile and execute the interfaces used. Check macro expansion as well as
procedure availability; module names alone do not prove equivalent behavior.

Follow the existing supported module form and explicit exports. Do not convert
all modules to `library`, `define-library`, or `define-module` merely to match
an example. Keep service startup, DOM mutation, and listener registration in
explicit entry procedures rather than incidental library initialization. Runtime
module reflection and an interactive REPL are separate features from ordinary
imports; enable their build support only when the task needs it.

Choose suitable target-provided Scheme libraries and SRFIs by semantic fit.
Records, list operations, multiple-value bindings, and simple partial
application remain useful choices, but verify the specific implementation.
Native Guile's hash-table or exception defaults are not a Hoot support list.
Follow the target's documented exception semantics, including proper unwinding
for recovery from non-continuable errors.

Share data transformations when both targets have actual callers. Keep host
effects in adapters and check the shared contract on both targets. Pay attention
to character positions versus UTF-8 bytes, JavaScript UTF-16 indices, number
conversions, equality, and exception behavior. Do not narrow unrelated native
server code to a portable subset.

## Scheme conventions

- Use ordinary parenthesized Scheme, not SRFI-105 curly-infix or SRFI-119 Wisp.
- Export intentional interfaces; keep helpers, record descriptors, and mutators
  private unless callers need them. Use prefixes, selection, or renaming to
  resolve real import ambiguity.
- Prefer records for stable fields and alists for small open metadata. Make
  table equality explicit and do not depend on hash traversal order.
- Treat published data as read-only. Local mutation is appropriate for owned
  construction and instance state; do not mutate shared caller inputs without a
  contract allowing it.
- Use `match` for supported structured destructuring, accessors for simple field
  reads, and clear multiple-value bindings. Prefer supported `let-values` and
  `let*-values`; a simple `cut` is useful when its evaluation semantics fit.
- Choose direct collection operations or a named loop according to clarity.
  Prefer ordinary procedures; use a hygienic macro only for needed binding or
  evaluation semantics, and check expansion on each target that uses it.
- Keep expected validation failures as structured data using the project's
  existing result shape. Propagate unexpected failures to a boundary with a
  recovery or reporting policy.

## Host interface contracts

Keep browser behavior in Scheme and the required JavaScript loading and host
adaptation in the infrastructure layer. Use explicit, narrow host operations
that fit the component. Do not invent a general DOM bridge or introduce
TypeScript for this purpose. Preserve existing JavaScript conventions and check
its actual host contract. Do not introduce a component or CSS framework as part
of a behavior or build change; styling is a separate project phase.

For each `define-foreign`, match the namespace, import name, argument types,
result type, and host implementation. Treat nullable external values explicitly
with the supported predicates; do not assume a missing DOM node is Scheme `#f`.
A Scheme record wrapping an external value distinguishes interfaces but does not
establish that a raw host object satisfies its promised contract.

Use typed FFI for concrete host operations and reflection when the host must
call a Scheme procedure or inspect Scheme values. Reflection preserves multiple
values, but result containers can differ between entry mechanisms. Verify their
actual shape against the bundled runtime and execution; the async example
records a documentation discrepancy. Reuse one runtime ABI only through the
toolchain's supported mechanism, not by moving reflected heap objects between
unrelated instances.

Keep numeric range, encoding, mutation, and ownership decisions at the boundary.
A Scheme exact integer, a Wasm integer, and a JavaScript Number are not
interchangeable for arbitrary values. Inspect conversion behavior for the
specific signature instead of relying on coercion.

## Initialization, callbacks, and asynchronous work

Load the matching reflection script and helper Wasm files produced by the
project's build. Resolve their URLs through the existing deployment scheme.
`Scheme.load_main` executes the entry program; importing libraries or fetching
the binary alone does not establish interaction readiness.

Give each mounted instance an owner and a cleanup path. Preserve the external
callback returned by `procedure->external` for subsequent removal; repeated
conversion need not preserve JavaScript function identity. Remove listeners with
the matching target, event type, callback, and capture setting. Clear owned
timers and release references after disposal. Garbage collection alone does not
unregister a callback held by a live host object.

When initialization awaits work, handle disposal or replacement during that wait
through the existing lifecycle. Avoid registering a second instance over an
active one or applying a stale result to a replacement view. Roll back resources
acquired before a partial initialization failure.

Use the actual asynchronous interface supported by the toolchain. In the Hoot
reflection API used by the examples, `Procedure.call_async` supplies resolve and
reject handles to the Scheme entry; `call-with-async-result` settles them. An
ordinary synchronous procedure does not acquire this protocol merely by being
called with `call_async`. Hoot's `(fibers promises)` integration and native
Guile's `run-fibers` scheduler are different entry mechanisms. Native I/O and
scheduling guidance does not apply to browser Wasm. Consult the selected Hoot
libraries for browser Promise integration; do not add a native Fibers dependency
to satisfy a compiled import.

Keep event callbacks short. If they start asynchronous work, connect it to an
async entry, settle both success and failure, and define who owns outstanding
work. A timeout that stops waiting is not necessarily cancellation of the host
operation. Do not introduce a scheduler or cancellation framework for code that
does not need one.

Preserve the page's existing no-script and failed-load guarantees. Handle
loading failures at the enhancement boundary while retaining usable rendered
content. Loading errors and later event-handler errors occur at different times;
a loader's `try` block does not catch every future callback failure.

## Documentation and verification

Use English for identifiers, code comments, and procedure docstrings, except
where an external interface requires another spelling. Preserve the language of
the product and existing documentation, including localized labels and sample
data. Keep machine-readable keys stable; do not translate names, quoted license
text, or upstream notices merely to satisfy a coding convention. Follow the
existing CLI diagnostic language and explicit user instructions.

Each handwritten top-level procedure needs a concise English docstring. Explain
non-obvious arguments, results, units, ownership, effects, and failures.
Generated FFI procedures do not need wrappers solely to attach docstrings.

Use the project's Scheme formatter and supported compiler warnings. Keep closing
parentheses with the final expression and wrap at expression boundaries without
changing literals. Add macro indentation support only when needed by existing
tooling.

Verify changed behavior with focused execution. A native SRFI-64 driver can
orchestrate Hoot without importing SRFI-64 into the Wasm program. Test relevant
shared cases in both targets; test host interactions in an available actual
browser, honoring the user's selected browser when specified. Use the browser
tools available in the session; no separate browser skill is required. Inspect
DOM, asset requests, and errors according to the changed behavior.

Reuse adequate tests and add a regression when a behavior change lacks coverage.
Exercise relevant initialization, repeated interaction, teardown, and failure
paths. Compile and load success, a Node host stub, and real DOM interaction
establish different facts. Follow project check requirements and report the
targets, results, warnings, and untested behavior accurately.
