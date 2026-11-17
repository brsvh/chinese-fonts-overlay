# Organizing native Guile work

Read when creating a feature without an established module or state protocol, or
when several individually simple procedures have become difficult to test. The
cases below separate observed upstream choices from proposed adaptations. They
do not prescribe a directory structure or a plugin framework.

## Haunt: prepare a description, then perform its effects

At
[Haunt a154de4a](https://git.dthompson.us/haunt/tree/?id=a154de4a02cfb11c185a851170400ad83b1c914e),
follow `reader.scm:read-posts`, `site.scm:build-site`, `builder/blog.scm:blog`,
and `artifact.scm:create-artifact` under `haunt/`.

The call chain has distinct jobs:

1. `read-posts` chooses a reader for each accepted input and obtains posts.
2. Each builder receives the site and posts and returns output descriptions.
3. `serialized-artifact` captures a destination, a value, and a serializer in an
   artifact's writer procedure.
4. `build-site` enumerates the builders' results; `create-artifact` creates
   parents, invokes each writer, and checks that its output exists.

This is useful separation at the point where several producers share an output
operation. The writer closure retains the value and serializer without making
every producer manage directories and ports. A test can inspect the prepared
description before performing effects, then exercise the writer in an isolated
directory. Arbitrary procedures inside an artifact mean that it is executable
application state, not an inert configuration format.

For a new small feature, start with a transformation and a procedure that owns
the I/O. Pass an ordinary value between them. Introduce an artifact record or
writer closure only when callers need deferred execution or multiple kinds of
output. A closure is unsuitable as a persisted job description; use explicit
data and an interpreter if persistence becomes a real requirement.

Haunt's `build-site` clears its existing output before writing. That is a static
generator's chosen update policy, not evidence of atomic publication or a safe
policy for a running server. If a feature promises that readers keep the old
version after an error, complete preparation first and publish only after
success through that feature's actual state owner.

## Haunt: order-sensitive selection needs an explicit contract

`reader-find` returns the first matching reader. `read-posts` reports an error
when an accepted input has no reader. This makes reader order meaningful; it
does not attempt every parser and silently accept the first non-error.

Use the same reasoning for a short sequence of adapters: define whether
selection is ordered, whether overlap is permitted, and whether failure after
selection should propagate. An absent optional adapter and a selected adapter
that cannot read its input are different outcomes. A single input format needs
no reader registry; start with its reader procedure.

Haunt's filesystem traversal accumulates posts, while its blog builder applies
an explicit chronological ordering. When callers promise an order, establish it
in the operation that owns that promise; do not derive it from traversal or
hash-table iteration. Keep a deterministic tie rule where equal keys matter.

## Establish a first feature without inventing a framework

For external data, choose the existing format and implement these operations as
ordinary procedures; combine them until separate callers or tests justify
separate modules:

- Reading owns encoding, ports, and source identity.
- Validation produces the feature's accepted value or contextual diagnostics.
- Preparation computes the state or output required by the consumer.
- Activation performs the effects and owns any partial-startup cleanup.

Pass accepted state explicitly. Use a record when fields have stable meanings; a
small alist is sufficient when the data remains open metadata. A new error
record is justified by consumers needing its fields, not by every operation
being fallible. Keep a command's exit decision outside reusable readers.

Loading a module should let a test obtain these procedures without starting the
feature. Haunt's `haunt-main` illustrates explicit command dispatch, but its
executable configuration and current-directory load-path extension are not
defaults for data-only applications.

## Exercise the organization, not only the helpers

Try a task with two valid inputs and one invalid input, then change one input's
shape. The change should have an identifiable validation boundary and should not
require editing every output producer. Observe that rejected input does not
activate partial state and that a failed writer is reported by its owner.

For ordered adapter selection, test two matching adapters and an error from the
selected one; verify the chosen policy rather than incidental call counts. For
deferred output, ensure captured values stay valid until writing finishes. A
passing record-accessor test cannot establish either of those properties.

These are task probes to adapt when the feature needs them, not mandatory
fixtures or a request to implement Haunt's site generator in another project.
