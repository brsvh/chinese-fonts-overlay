# Node.js tools

Read for command-line programs and Node.js adapters around processes, files,
structured data, or HTTP. Obtain commands, credentials policy, and verification
scope from the target project.

## Processes and command boundaries

Reuse the existing process wrapper when it provides the required contract. Pass
the program and argument array separately to `spawn`, `execFile`, or their
synchronous counterparts. Keep shell execution disabled for data-bearing
arguments. Shell quoting is not a replacement for an argument vector; also check
whether a tool requires `--` before operands beginning with a hyphen.

Check launch errors, termination signals, exit status, and output validity as
distinct outcomes. Parsing stdout is appropriate only after successful
execution. Keep protocol stdout separate from diagnostics on stderr. Specify
encoding only for text output, and bound buffered output or stream larger data.

Synchronous I/O and process calls can suit a sequential maintenance CLI. Use
asynchronous APIs when the process must keep handling concurrent requests,
timers, or cancellation. A synchronous call blocks those handlers even inside an
`async` function. Choose based on the actual execution model.

For asynchronous subprocesses, own both launch and completion failures. When
collecting output, account for stream closure as well as process exit. A timeout
or signal sent to the child is not proof that it and its descendants have
stopped; settle the operation according to the process contract before removing
resources it may still use.

Resolve module-relative assets with `new URL(..., import.meta.url)` and convert
file URLs with `fileURLToPath` when a path is needed. Resolve user-supplied
paths against the documented working directory. Preserve URL encoding and pass
inputs to external evaluators as data through their supported interfaces.

## Files and structured output

Validate data before preparing persistent replacements. When replacing a file,
use the project's existing temporary-file and rename procedure on the same
filesystem. A rename does not serialize concurrent writers or guarantee crash
durability; retain any required lock, expected-revision check, and durability
steps. Clean up only temporary paths owned by the operation.

Close file handles and release streams in all outcomes. Use stream APIs that
propagate errors and respect backpressure for large transfers. Do not turn a
stream into an unbounded list of chunks merely to simplify the caller.

For externally supplied paths, validate the allowed root, path components, and
symlink behavior before access. Lexical normalization alone does not prove
containment through symlinks. Preserve the project's archive and file-type
validation rather than adding a second partial check.

Keep a machine-readable result complete and separate from progress messages. At
the CLI boundary, report failures and set a failing exit status. Prefer
`process.exitCode` when pending output or cleanup must finish. Libraries should
propagate errors to their caller rather than terminate the process.

## HTTP and remote state

Check HTTP status explicitly; `fetch` can fulfill for an unsuccessful HTTP
response. Validate both the response shape and fields before using them. Bound
response bytes while consuming the body; a declared content length alone is
insufficient. Keep the timeout or cancellation scope alive through body
consumption, not merely until response headers arrive.

Consume or cancel response bodies on paths that discard them. Preserve the
existing redirect and credential policy. A redirected URL is a new destination;
do not forward authorization headers to another origin by default. Keep secrets
and private payloads out of diagnostic strings.

Retry only failures that the operation's contract makes transient and safe to
repeat. Bound attempts and elapsed time, respect server retry guidance, and make
waits cancellable when needed. A timeout can leave a remote write already
committed. Verify its state or use the existing idempotency mechanism before
retrying a mutation.

Keep HTTP status, redirects, and body handling in the transport layer. The
consumer knows which producer, revision, and record schema it expects. Validate
those together before using the record. When retrying a conditional write after
a conflict, read the current state and apply the pending update to that state.
Preserve other writers' completed work.

Exercise the command through the same argument and output interfaces as its
caller. A syntax check cannot catch a missing binding reached only on an HTTP
error. With temporary destinations or a local replay, check the exit status,
diagnostic, and any output left by that failure. Use the project's normal
verification policy for external writes.
