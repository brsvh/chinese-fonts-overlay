# A real extension's resource graph

Read when a C adapter retains callbacks or creates children attached to a native
parent. The case is
[Guile-SSH baa338e6](https://github.com/artyom-poptsov/guile-ssh/tree/baa338e6468c6e7489afcbb745df4bc569faabe9),
particularly `libguile-ssh/session-type.c`, `channel-type.c`, and
`tests/manual/channel-leak.scm`. Its SMOB and historical port implementation are
evidence to inspect, not the required representation for a new extension.

## Follow both reachability and external ownership

The session's mark function marks its channels and callbacks. Channel creation
stores its Scheme session owner and protects that owner; channel close removes
the child from the session, releases channel/callback resources as appropriate,
and removes protection. The session's cleanup disconnects and releases the
underlying libssh session. Session shutdown also has a procedure that closes
registered channels until the collection is empty.

This is more than a pointer plus a finalizer. There are distinct edges:

| Edge                        | Reason                                        | End condition to inspect                       |
| --------------------------- | --------------------------------------------- | ---------------------------------------------- |
| Session to Scheme callbacks | Native callbacks need reachable Scheme values | Callback registration/session lifetime ends.   |
| Session to channels         | Parent operations must find live children     | Child close removes the registration.          |
| Channel to session          | Child operations need a live parent           | Channel close removes protection.              |
| Wrapper to native resource  | Native allocation needs its matching release  | Explicit close or permitted finalization path. |

For a new wrapper, draw only the edges its API actually needs. A single owned
buffer can use the much smaller
[foreign-object example](guile-extensions.md#an-explicitly-closable-foreign-object).
Add a child registry when parent shutdown must enumerate children, not merely
because another extension has one. Reachability prevents collection; it does not
prevent explicit close or concurrent access. State and synchronization must
still enforce those contracts.

## Remote EOF is not complete local cleanup

`channel-type.c:ptob_close` distinguishes a remotely closed channel, a connected
parent, and a resource already released with its parent. These cases require
inspection of libssh's ownership rules before selecting the release call.
Clearing local state and unregistering callbacks/protection remain separate
responsibilities. Do not free a child twice because both parent and child have
close operations.

The manual regression records an externally visible channel leak: repeatedly
opening, reading, and closing remote pipes on one connection eventually caused
the server's session limit to be exhausted. Reading all output was not proof
that the native channel was released. The test's repeated operation exposes a
resource-lifetime failure that one successful command does not.

For a local adaptation, count acquisition and release in a stub backend, then
run a bounded open/use/close loop. Include parent-first close, child-first
close, repeated close, and a failure after allocation but before publication.
Assert valid state and resource balance, not memory addresses or a guessed GC
timing. A real backend check is still needed if its ownership behavior matters.
Do not run the upstream unbounded SSH test against a user's session.

## Callbacks add a second failure path

Before any callback into Scheme, account for every native resource already
acquired and every rooted value. A Scheme nonlocal exit skips ordinary C tail
cleanup. Use the selected Guile cleanup/catch contract, and make the callback's
external return protocol explicit when it cannot propagate Scheme control flow.
The presence of a mark function alone does not establish callback error safety.

The upstream source is not blanket proof of correctness for all failure paths.
Check its callers and library version before copying an acquisition sequence.
For the new extension, identify the point at which ownership transfers to the
wrapper, how partial initialization unwinds, and which operations reject a
closed wrapper. These decisions keep a small adapter sufficient without
introducing a general native-resource framework.
