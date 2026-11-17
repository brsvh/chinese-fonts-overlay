# Awaiting a host Promise

Read when compiled Scheme invokes a Promise-returning host operation. This
reference covers Hoot's async and FFI contract. The optional browser action
section connects that contract to a concrete Clipboard host call.

## Own one asynchronous result

`await` from `(fibers promises)` suspends in the supported async context until a
host Promise settles. Fulfillment supplies its value; rejection raises a Scheme
exception carrying the host rejection as context. It is not a native Guile
`run-fibers` entry or a Scheme `delay` promise.

Put both the host call and its wait inside the owning operation. A host function
can throw before returning a Promise, as well as return one that later rejects.
A raw JavaScript throw from an import is not automatically a Scheme exception.
For a Promise-based host contract, normalize synchronous throws to rejected
Promises in the adapter, for example with an `async` function. Then `await` can
deliver both kinds of failure to Scheme's exception machinery.

At a reflected async entry, `call-with-async-result` forwards the thunk's values
or Scheme exception to the handles supplied by `call_async`. An immediate raw
host throw can instead escape to the JavaScript reflection call; do not rely on
that path to provide the same Scheme cleanup and error handling after
suspension. Do not report success when the host operation has merely started.

## Small compiled fixture

Save this as `host-work.scm` in an isolated fixture. Modes select deterministic
host outcomes solely for testing; they are not an application API design.

```scheme
(import (scheme base)
        (fibers promises)
        (hoot ffi))

(define-foreign begin-host-work
  "probe" "beginWork" i32 -> (ref extern))

(define (run-host-work resolved rejected mode)
  "Await the host operation selected by MODE and forward its outcome.
Report completion only after fulfillment; propagate rejection and host throws."
  (call-with-async-result
   resolved rejected
   (lambda ()
     (await (begin-host-work mode))
     "Completed")))

run-host-work
```

Compile with the selected toolchain and its matching runtime resources. With
Hoot 0.9.0, the existing `hoot compile --bundle -o ...` interface can produce
this fixture. This illustrates the target program, not an additional build rule.

The host below assumes `Scheme` is loaded from that matching runtime and both
URLs are supplied by the fixture. It starts an operation and observes the
reflected result; no DOM or browser permission behavior is implied.

```javascript
const [runHostWork] = await Scheme.load_main(wasmUrl, {
  reflect_wasm_dir: new URL(supportUrl, document.baseURI).href.replace(/\/$/, ""),
  user_imports: {
    probe: {
      async beginWork(mode) {
        switch (mode) {
          case 0:
            return;
          case 1:
            return Promise.reject(new Error("Expected host rejection"));
          default:
            throw new Error("Expected synchronous host failure");
        }
      }
    }
  }
});

const values = await runHostWork.call_async(0n);
const message = values.reflector.car(values); // "Completed" in Hoot 0.9.0.

let failures = 0;
for (const mode of [1n, 2n]) {
  try {
    await runHostWork.call_async(mode);
  } catch (error) {
    failures += 1;
  }
}
if (message !== "Completed" || failures !== 2) {
  throw new Error("Host outcome contract failed");
}
```

Declaring `beginWork` async ensures that its synchronous throw also becomes a
rejected Promise. The adapter has a concrete normalization responsibility, not a
redundant catch that swallows the failure.

The exact-integer arguments use BigInt for the inspected reflection runtime;
`beginWork` receives the converted Wasm `i32` as a JavaScript number. The async
result is the reflected Scheme list described in
[host examples](host-examples.md#asynchronous-entry), not a native JS array. Do
not assume the rejection object is a JavaScript `Error` with a `.message`
property; inspect the selected runtime's exception representation when reporting
its details.

## Verify settlement and ownership

In addition to the fixture's fulfilled, rejected, and synchronous-throw
outcomes, hold a Promise unresolved and verify that the Scheme operation has not
reported completion. Resolve it through a test-controlled handle, then observe
completion. Bound the entire test so a missing settlement fails instead of
hanging.

If an application stops waiting or its owner is disposed, the host operation may
still finish. Keep the existing ownership policy for late results and resources;
this example neither cancels the Promise nor promises that an external operation
has stopped. Do not introduce a generic cancellation framework to run it.

## Source basis

[Hoot 0.9.0](https://codeberg.org/spritely/hoot/src/tag/v0.9.0) provides
`lib/fibers/promises.scm` (`await`, `await-promise-operation`, and
`call-with-async-result`) and `reflect-js/reflect.js`. The installed source and
runtime establish settlement and representation behavior. The fixture is an
original small test of those contracts, not a browser compatibility claim.

## An optional browser action: copying a link

Read this section only for a user-activated asynchronous browser operation. The
[retained action](../examples/browser-probe/action.scm) applies the
[interaction policy](interaction-state.md) to one actual host API. It begins the
operation in Scheme, ignores a duplicate while busy, displays success only after
fulfillment, and keeps a failure outcome distinct from a successful empty value.
Only settlement of the accepted token may update the display.

The
[Clipboard interface](https://w3c.github.io/clipboard-apis/#async-clipboard-api)
is restricted to secure contexts and browser permission/activation policy. Check
the actual operation, not just whether `navigator.clipboard` exists. Initialize
Hoot before enabling the enhancement and invoke the host operation from the
user's action without unrelated asynchronous work first; a permission or
user-activation grant is not made durable by saving an event object. The adapter
normalizes missing API access and host throws into rejection so Scheme can
retain the ordinary link and display manual-copy guidance.

A disposal token prevents stale publication, not the external clipboard write
itself. A request already given to the browser can still complete after the
component disappears. Do not label a timeout, disposed owner, or disabled button
as cancellation of that operation. This example does not persist a permission
grant, poll the clipboard, or add a general browser API framework.
