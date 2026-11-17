# Verification

Choose checks for the changed ownership or boundary contract. Sources include
the
[Clang AddressSanitizer documentation](https://clang.llvm.org/docs/AddressSanitizer.html),
[UndefinedBehaviorSanitizer documentation](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html),
and Trail of Bits'
[harness guidance](https://appsec.guide/docs/fuzzing/techniques/writing-harnesses/).
The community
[address-sanitizer skill](https://github.com/trailofbits/skills/blob/main/plugins/testing-handbook-skills/skills/address-sanitizer/SKILL.md)
is useful for report interpretation, not a source of unconditional runtime flags
or permission to install a separate test framework.

## Match tests to contracts

| Change                | Useful cases                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Counted input         | Empty input; documented NULL/zero combinations; embedded NUL; non-ASCII bytes; malformed encoding when validation is promised. |
| Allocation arithmetic | Addition/multiplication boundary before allocation; allocation failure; unchanged prior owner/output on failure.               |
| Resource acquisition  | Failure after each meaningful acquired stage; matching cleanup once; original error retained where promised.                   |
| Foreign object        | Round-trip data; wrong type; explicit close; documented repeat-close behavior; rejected access after close.                    |
| Guile callback        | Ordinary result, thrown exception, and conversion/type error; external cleanup on both normal and nonlocal exit.               |
| Rust C ABI            | A real C caller linked to the Rust export; correct status and output mutation; matching target types and actual symbol.        |
| Concurrent callback   | Deregistration and outstanding-call behavior when the API supports concurrency, not just a single-thread happy path.           |

Do not deliberately dereference arbitrary invalid pointers to test a contract
that requires valid storage. Check supported invalid inputs such as NULL, an
out-of-range numeric value, or a closed typed handle. Use a separate diagnostic
fixture for proving that a sanitizer is actually active.

For the byte-copy example, force malloc failure in a test build and verify that
no successful output is published. A test allocator or a platform-supported link
wrapper can provide deterministic injection without changing the public API.
Restore the normal allocator for the ordinary sanitizer run. Do not try to
exhaust the host's memory to induce this branch.

## Compile and execute through the real boundary

Use project warnings and build rules. For a small standalone fixture, warnings
such as -Wall, -Wextra, and -Wconversion can expose mistakes, but assess the
actual compiler, headers, and supported language standard before making them
global requirements. Do not suppress a third-party header warning by hiding
diagnostics for all handwritten code. A supported system-header include path can
separate dependency-header diagnostics from those of the adapter. Conversely,
global -Werror is a project policy, not a portable language rule.

Check header self-containment and declaration agreement when an interface
changes. Compile implementations against their own public header; ensure a
foreign-language smoke test actually links and executes the exported symbol.
Keep generated objects and test libraries in the chosen build directory.

For the Guile fixture, build an extension from the documented fragments and load
init_sample through load-extension in a fresh process. Check non-ASCII and
embedded-NUL round trips, byte-count callbacks, exceptions, and typed close/read
behavior. A test-only native cleanup counter can observe the release handler
without changing production interfaces. Keep counters synchronized if a test
also observes asynchronous finalizers.

Do not use a fixed number of gc calls as a portable promise that a particular
finalizer will have run. Explicit close provides deterministic resource tests;
GC stress can supplement them but does not prove reachability for every compiler
optimization. Check both optimized code and the owner-liveness reasoning when
the bridge exposes a pointer into a finalizable object.

## Sanitizers and fuzzing

For supported native toolchains, an isolated C fixture can use
`-fsanitize=address,undefined -fno-omit-frame-pointer -g` at compilation and the
needed sanitizer flags at final linkage. Instrument relevant code, not merely
the tiny harness. Verify that the instrumented executable really starts and that
a deliberately faulty separate control is detected before relying on a silent
run as evidence.

A sanitized shared extension loaded by an unsanitized Guile process may need
runtime-loading arrangements. GC and uninstrumented libraries also limit what
leak reports or a clean run establish. Investigate mismatches and use the
selected tool's documented integration; do not globally disable leak checks or
suppress reports just to make the fixture pass. A standalone C sanitizer pass
does not imply that Rust or Guile internals were instrumented.

Use ThreadSanitizer separately when supported and when concurrency is the
changed concern; it is not an addition to the same AddressSanitizer build. Use
focused static analysis or Valgrind when they answer a concrete unresolved
question. Report limitations instead of installing every possible checker.

For a parser, scanner, or decoding boundary that accepts untrusted data, a
bounded fuzz harness can add useful evidence: start with valid and malformed
seeds, handle empty inputs, bound resource use, reset per-input state, and
preserve a reproducer. No crash is weaker than semantic correctness; compare the
relevant structural or round-trip property when there is a justified oracle.
Keep byte handling and business validation separate.

## Example validation

The documented fragments were compiled and executed in a disposable fixture on
2026-09-19 with GCC 15.3.0, Guile 3.0.11, and Rust 1.97.1. Header
self-containment, the GNU-style helper, counted copying, forced malloc failure,
and a real C caller of the Rust export passed. The standalone byte-copy fixture
passed AddressSanitizer and UndefinedBehaviorSanitizer with leak checking
enabled; a separate deliberate buffer overrun was detected.

The optimized Guile extension passed 40 SRFI-64 checks, including embedded NUL,
Unicode, callback exceptions and type errors, deterministic cleanup counters,
close/read behavior, reads during GC stress, and a complete Guile-C-Rust call.
Finalizer idempotence was exercised by directly invoking the finalizer through a
test-only helper, not by assuming a GC scheduling deadline. Dependency headers
were treated as system headers while strict warnings remained enabled for
handwritten C.

These are example checks, not toolchain requirements or proof of all runtime
paths. The standalone C sanitizer run did not instrument Guile or Rust
internals. Concurrent use, foreign-thread callbacks, and cross-compilation were
outside this fixture's contract.

## Repeat the reference checks

This optional skill fixture covers C/Guile/Rust examples. Its Python driver and
Rust toolchain are not application dependencies or required checks for font
tools. Maintained test drivers follow the target project's language and build
rules.

The retained [runner](../scripts/check-examples.py) extracts the current
reference fences and assembles the checked fixture. Invoke it by its resolved
skill path, passing a new output directory. It writes generated sources and
per-step logs only there; it does not fetch tools or modify the reference files.

The retained runner targets Linux/ELF native builds; its `.so` and linker flags
are not a Windows, macOS, or cross-compilation recipe. Use Python 3.10 or newer,
a GCC-compatible compiler with AddressSanitizer/UBSan, a Rust compiler
supporting edition 2024, pkg-config, and Guile 3 development files. Select tools
through `CC`, `RUSTC`, `PKG_CONFIG`, `GUILE`, and the environment's search
paths; these command variables accept shell-style argument lists without running
a shell. Verify the actual sanitizer support. Report unsupported platforms or
missing dependencies without treating skipped checks as passes. The Guile
extension is tested separately from the standalone sanitizer executable.
