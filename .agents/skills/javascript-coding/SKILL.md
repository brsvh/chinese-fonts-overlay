---
name: javascript-coding
description: >-
  Write, review, and refactor handwritten JavaScript for Node.js tools, browser
  interactions, and host adapters. Use when changing module boundaries, control
  flow, asynchronous work, or observable behavior at a JavaScript interface.
---

# JavaScript Coding

Read the applicable project guidelines and find the caller of the code being
changed. A workflow command, a script loaded by a document, and a Wasm import
each determine how the code runs. Use the runtime and formatter selected by the
project. Edit the handwritten source for generated assets.

- For process execution, files, HTTP, or persistent records, read
  [Node.js tools](references/node-tools.md).
- For DOM ownership, navigation, or host callbacks, read
  [Browser and host interfaces](references/browser-host.md). Use the
  `hoot-coding` skill as well when a change crosses a Guile Hoot boundary.

## Names, modules, and layout

Name operations for what callers ask them to do. Keep external field names and
command names stable when renaming local bindings. Follow local naming for
functions, values, and classes. Group functions by the data or behavior they
own. Gather callers before moving a helper into a shared module. A transport
client can then be used without importing a particular consumer's validation or
publication policy.

Use named exports for operations other modules call. Keep local helpers private
and run startup code at its entry point. Check import direction after a split,
including imports reached only on failure. In native ES modules, use explicit
relative file extensions and the `node:` prefix for Node built-ins. Preserve the
loading convention of existing classic scripts and CommonJS callers.

Let blank lines mark changes of purpose within a function. For example, leave
space between validating input, computing a result, and writing it. Keep a
request next to the check on its response. Use a named intermediate value or a
loop when a chain obscures ordering or side effects. Let the formatter handle
indentation and wrapping.

## Data and asynchronous work

Validate external data at the point where its meaning is known. Preserve
distinctions between an absent field, a false value, zero, and an empty
collection. Check own keys for dictionaries, units for sizes, and integer ranges
for identifiers. Preserve duplicate-key checks, field ordering, and encoding
when serialized bytes contribute to a digest. Copy caller-owned arrays before
sorting them unless mutation is part of the interface.

Give each Promise a caller that awaits, returns, or handles it. An event handler
may have to handle its own rejection. Bound concurrent operations when input
size can grow. When a view or request is replaced, abort outstanding work where
supported and check ownership again before applying a late result. Release
resources only after their users settle. If cleanup runs in a `finally` block,
await the operation inside the `try` so cleanup covers its full lifetime. Keep
the original error available when adding context or handling a cleanup failure.

## Refactoring and verification

Identify the observable contract before changing the implementation. Check the
inputs callers can supply, the values or bytes they receive, and what remains
after a partial failure. Reuse an existing validator or a runtime primitive when
it provides the same behavior. Remove a field, export, or intermediate file only
after checking its readers, including workflow steps and consumers of persisted
data.

Format the affected files and exercise the normal entry point. After moving code
between modules, check imports and name resolution with the project's tools,
then run a success case and a relevant failure case. For changes to a serialized
format or a retry path, compare outputs and exercise an interrupted or repeated
operation. Report what the checks covered.
