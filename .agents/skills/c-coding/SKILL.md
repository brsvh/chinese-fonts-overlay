---
name: c-coding
description: >-
  Write, review, and refactor C in GNU style with explicit pointer, ownership,
  error, and interface contracts. Use for handwritten .c and .h files, native
  font inspection and rendering tools, library adapters, and native language
  boundaries.
---

# C Coding

Use GNU C style for handwritten code, subject to the target project's explicit
local rules. Read its applicable `AGENTS.md` and build configuration before
selecting paths or commands. For font inspection or rendering, additionally read
[font tools](references/font-tools.md).

Resolve bundled references and scripts relative to this skill's installed
directory, independently of the target checkout and current working directory.
Use the target project's declared environment; do not assume Nix, a particular
compiler installation, or a sibling skill is available. Discover companion
skills by name in the current session when their execution targets are involved.

Follow the project's selected C standard, supported targets, and dependency
versions. Reference fixtures are examples, not application structure or new
dependencies. Distinguish handwritten code from generated or vendored output;
change its maintained source instead of editing generated results.

Read only the reference needed for the task:

- [Extension lifecycle](references/extension-lifecycle.md): Guile-SSH ownership,
  child registration, and a real repeated-operation leak case.
- [GNU style](references/gnu-style.md): layout, declarations, naming, comments,
  and the scope of formatting changes.
- [Memory and interfaces](references/memory-and-interfaces.md): counted data,
  allocation arithmetic, failure semantics, and release functions.
- [Guile extensions](references/guile-extensions.md): conversions, dynamic
  cleanup, foreign objects, GC reachability, and thread entry.
- [Rust boundaries](references/rust-boundaries.md): C-compatible types, borrowed
  buffers, matching deallocators, and control-flow boundaries.
- [Verification](references/verification.md): warning selection, boundary cases,
  failure injection, sanitizers, and native integration checks.

The references combine upstream documentation and original small examples.
Source revisions and validation versions identify evidence, not dependencies.

## Apply GNU C style

Use two-space indentation steps and GNU brace placement. Put a function's return
type on the preceding line, its definition name at column one, and its outer
braces at column one. Indent control-statement braces two spaces from the
control statement and their contents another two spaces. Put a space before the
opening parenthesis of function calls and declarations, and after commas. Align
continued arguments; break expressions before operators. Keep source lines
within 79 columns where practical.

Use descriptive English names with lowercase words separated by underscores;
reserve uppercase for macros and enum constants. Document function contracts and
meaningful static state with English block comments, complete sentences, and two
spaces between sentences. Preserve names and signatures required by foreign
APIs. Follow [GNU style](references/gnu-style.md) for details and examples.

Apply this default to new and touched handwritten C. Honor an explicit local
exception; keep unrelated reformatting out of a focused change. Do not reformat
generated or vendored sources, introduce old-compiler compatibility, or change
repository layout merely to resemble a GNU package.

## Define the boundary before the implementation

For each public operation, establish argument validity, units, ownership,
mutation, lifetime, success and failure outputs, and threading assumptions. Use
existing error and naming conventions rather than creating a second API
framework. Keep adapters focused on conversion, lifetime, and error translation;
implement domain behavior in the layer assigned by the project.

Distinguish nullable from required pointers, bytes from elements and characters,
and a borrowed view from an owned allocation. A NULL check cannot prove that a
non-NULL pointer is live, aligned, large enough, or free of conflicting access.
State those caller obligations; do not claim arbitrary addresses are validated.
Keep private helpers static and exported symbols intentional.

## Types, ranges, and representation

- Use types matching the API's units and range, such as size_t for object sizes.
  Check signedness, narrowing, addition, and multiplication before performing
  operations that can overflow. A cast after overflowing does not repair it.
- Distinguish the size of an object from the size of its pointer. Prefer
  `sizeof *pointer` for allocations tied to that pointer's type. Handle empty
  input deliberately instead of relying on `malloc (0)` or
  `realloc (pointer, 0)`.
- Use pointer-plus-length interfaces for counted data. Specify whether text is
  UTF-8, locale encoded, or opaque bytes, and whether embedded NUL is accepted.
  strlen and NUL-terminated APIs cannot stand in for arbitrary buffer lengths.
- Respect object bounds, alignment, aliasing, and lifetime. Use defined byte
  copies or decoding instead of unaligned casts and type-punning through an
  incompatible pointer. Struct padding and host endianness are not a file or
  wire format; memcmp on structs is not general value equality.
- Give ctype functions an unsigned-char value or EOF, preserving EOF before
  conversion. Do not use byte classification to implement Unicode semantics.
  Match format strings to argument types; do not pass external text as a format.

## Ownership and cleanup

Pair each resource with its actual release operation: an allocator's matching
free, a library destructor, a file close, or callback deregistration. Do not
free borrowed storage or use libc free on an opaque Rust-owned allocation.
Document transfers and ensure every failure path retains or releases ownership
as promised. Clear an owner's handle after release when that is its state model;
this does not invalidate other aliases automatically.

Use a temporary result for realloc so failure does not lose the old allocation.
Define the zero-size case separately. Initialize outputs according to the
contract and publish owned results only when construction succeeds. Preserve old
state on failure when the operation promises that behavior.

Prefer direct early returns before resource acquisition; a short goto cleanup
chain is appropriate when several acquired resources need ordered unwinding.
Check partial acquisition and cleanup errors that affect the result. Capture
errno before cleanup can replace it, and only use errno when the failed API
defines it. Ordinary cleanup labels do not handle Guile nonlocal exits; use the
Guile reference when calls can throw or invoke Scheme.

Use assertions for internal invariants, not as the only validation for external
input or an operation whose side effects are required. Library adapters should
report failures through their API rather than terminating the embedding process
or silently converting failure into an empty successful result.

## Interfaces, callbacks, and concurrency

Keep public headers self-contained, guarded, and limited to required types and
dependencies. Include the implementation's own header to check declaration
agreement; place a required configuration header first when the project needs
that ordering. Follow existing symbol prefixes and header conventions rather
than imposing a vendor prefix or Doxygen boilerplate on every helper.

Use const for borrowed read-only access where appropriate; it does not establish
thread safety or ownership. Prefer typed functions to macros with repeated
argument evaluation. Document unavoidable macro evaluation rules and use the
project's supported language facilities rather than incidental compiler
extensions.

Callbacks need an exact function signature, context lifetime, and a defined
registration/unregistration contract. A function-pointer cast cannot repair an
ABI mismatch. Stop or synchronize outstanding callbacks before releasing their
context. Address reentrancy and concurrent close/use where the real API permits
them; a tombstone alone is not synchronization.

Follow the existing scheduler and locking model. volatile does not make shared
state atomic or synchronize threads. Use supported atomics or locks for actual
shared access, and identify calls that can block a Guile/Fibers scheduler
thread. Do not introduce a threading abstraction for a synchronous adapter.

## Integrate and verify

Use the project's build and selected compiler. For an Autotools project, edit
its maintained `Makefile.am` and `configure.ac`, then regenerate derived files
through its documented bootstrap/configure workflow. Other build systems keep
their own source of truth. Use available `guile-coding` or `nix-coding` guidance
when changing those languages. Do not add a second build implementation or a
runtime dependency merely to run an educational fixture. Rust and extension
references apply only when the changed code crosses those boundaries.

Use English for identifiers, code comments, and procedure docstrings, except
where an external interface requires another spelling. Preserve the language of
the product and existing documentation, including localized labels and sample
data. Keep machine-readable keys stable; do not translate names, quoted license
text, or upstream notices merely to satisfy a coding convention. Follow the
existing CLI diagnostic language and explicit user instructions.

Explain ownership, bounds, cleanup, and unusual control flow where readers need
them; avoid comments that merely repeat the statement. Inspect the target's
formatter configuration and how it is maintained before using clang-format.
Using the tool is optional: manual formatting or an editor is acceptable when
the result follows the style. Do not make clang-format a prerequisite for C work
or add it to treefmt, commit hooks, or CI without a separate request. Formatting
cannot establish API safety; see [GNU style](references/gnu-style.md) for
optional commands and the configuration source.

Verify observable contracts and realistic failure paths. Match checks to the
change: compiler diagnostics, focused native tests, actual Guile/Rust loading,
or sanitizers for relevant memory operations. A clean sanitizer run covers only
instrumented executed paths. Do not mandate a new framework, a benchmark, or a
full fuzzing campaign for every small edit.
