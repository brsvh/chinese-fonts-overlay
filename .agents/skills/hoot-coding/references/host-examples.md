# Shared Transformations and Host Boundaries

Read the section that matches the task. These original examples build on Hoot's
[project template](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/examples/project-template),
[FFI implementation](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/lib/hoot/ffi.scm),
and
[reflection implementation](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/reflect-js/reflect.js).
The template's library/import separation is useful; its directory layout and
page design are not requirements. Source revisions identify inspected evidence,
not a toolchain version to install.

Contents: [shared transformation](#shared-transformation),
[owned callback](#owned-callback), [browser loader](#browser-loader),
[asynchronous entry](#asynchronous-entry), and
[contract pitfalls](#contract-pitfalls).

## Shared transformation

Only share this module if two actual callers need it. Keep richer native Guile
facilities available elsewhere. This scratch module uses the template's
`library` form and contains no host effects. Save it as `example/preview.scm`:

```scheme
(library (example preview)
  (export preview-text)
  (import (scheme base))

  (define (preview-text text limit)
    "Return at most LIMIT Scheme characters of TEXT, treating it as read-only.
LIMIT must be a nonnegative exact integer. Count characters, not UTF-8 bytes
or user-perceived grapheme clusters; signal an error for invalid arguments."
    (unless (and (string? text) (exact-integer? limit) (>= limit 0))
      (error "Expected text and a nonnegative character limit" text limit))
    (substring text 0 (min limit (string-length text)))))
```

The imports must work in the compiled target, not just the compiler's Guile
process. Check required Unicode operations rather than inferring them from an
ASCII-only example. A Scheme character limit also differs from a DOM selection
offset measured in UTF-16 code units.

## Owned callback

Save as `example/status.scm`. Loading the library defines bindings without
changing the DOM. Calling `mount-status!` installs one listener and returns a
procedure that removes it. The instance owns its count and external callback.

```scheme
(library (example status)
  (export mount-status!)
  (import (scheme base)
          (example preview)
          (hoot ffi))

  (define-foreign set-status-text!
    "status" "setText" (ref string) -> none)

  (define-foreign add-update-listener!
    "status" "addListener" (ref extern) -> none)

  (define-foreign remove-update-listener!
    "status" "removeListener" (ref extern) -> none)

  (define (mount-status!)
    "Initialize this host instance and return an idempotent cleanup procedure.
Count button updates in owned state. The caller must dispose the instance
before mounting another one on the same elements."
    (let* ((active? #t)
           (updates 0)
           (callback
            (procedure->external
             (lambda (event)
               (when active?
                 (set! updates (+ updates 1))
                 (set-status-text!
                  (string-append "Updates: " (number->string updates))))))))
      (set-status-text! (preview-text "Ready for interaction" 5))
      (add-update-listener! callback)
      (lambda ()
        (when active?
          (remove-update-listener! callback)
          (set! active? #f))))))
```

A host event supplies an argument even when the callback ignores its contents.
The same external callback is retained for removal. In the inspected reflection
implementation, converting a procedure to an external function creates a new
JavaScript wrapper each time. The
[DOM event contract](https://dom.spec.whatwg.org/#dom-eventtarget-removeeventlistener)
requires a matching event type, callback identity, and capture flag.

The minimal adapter below registers one listener as its final acquisition. If a
real initialization sequence acquires several listeners, timers, or
subscriptions and can then fail, unwind the completed acquisitions too. If a
host method can partially succeed and then throw, give that method a rollback
contract; this example assumes the ordinary DOM registration operation.

## Browser loader

The entry program `browser-main.scm` returns its mount procedure without
initializing the instance or changing the DOM:

```scheme
(import (example status))

mount-status!
```

The following `browser.js` expects an existing `root` with `[data-status]` and
`[data-update]` descendants. The latter is a button with `type="button"`. Load
the matching `reflect.js` before invoking this function. Pass actual served URLs
for the application binary and its reflection support directory.

```javascript
/** Mount one status enhancement; return cleanup, or null if markup is absent. */
async function mountStatus(root, wasmUrl, supportUrl, signal) {
  const status = root?.querySelector("[data-status]");
  const button = root?.querySelector("[data-update]");
  if (!status || !button || signal?.aborted) return null;

  const runtimeDirectory = new URL(supportUrl, document.baseURI)
    .href.replace(/\/$/, "");
  const [mount] = await Scheme.load_main(wasmUrl, {
    reflect_wasm_dir: runtimeDirectory,
    user_imports: {
      status: {
        setText(text) {
          status.textContent = text;
        },
        addListener(callback) {
          button.addEventListener("click", callback, false);
        },
        removeListener(callback) {
          button.removeEventListener("click", callback, false);
        }
      }
    }
  });

  // Loading may finish after the owner is gone. Mount only while still owned.
  if (signal?.aborted) return null;
  const [dispose] = mount.call();
  return () => { dispose.call(); };
}
```

The entry must return the initializer rather than call it. Checking ownership
only after `load_main` returns cannot undo DOM writes performed by its entry. An
AbortSignal here invalidates publication; it does not cancel runtime fetches.
Dispose an already mounted instance through its returned cleanup procedure.

The inspected runtime appends a slash and a helper filename to
`reflect_wasm_dir`. Resolve the configured directory against the document and
remove its trailing slash, as above: passing a bare `/` unchanged would turn
`/wtf8.wasm` into `//wtf8.wasm`, a request to a different host. This is a loader
contract to check against the actual runtime, not a prescribed asset location.

The owner awaits `mountStatus` once, keeps the returned cleanup, and invokes it
before replacement or disposal. The owner also catches a rejected mount promise
and reports it while preserving the rendered page. If that owner can disappear
while loading is pending, mark it inactive and immediately clean up a late
result. Reuse its existing lifecycle; do not introduce a global component
registry for this example.

`Scheme.load_main` returns the entry's values as an array. Here its first value
is a reflected procedure: invoke its `.call()` method to run cleanup. A loading
promise resolves after the entry executes, not after every future event.
`textContent` writes text rather than interpreting Scheme output as markup.

The loader handles optional absent markup without starting Wasm. Once both
elements exist, missing imports or execution failures remain errors. Catch them
at the owner boundary rather than returning a successful empty instance.

## Asynchronous entry

Hoot's
[Fibers example and promise API](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/doc/hoot.texi)
and
[JavaScript reflection documentation](https://files.spritely.institute/docs/guile-hoot/latest/JavaScript-reflection.html)
define a different calling protocol for asynchronous procedures. This scratch
program `async-main.scm` returns one such procedure. The deliberate failure
argument makes both settlement paths executable.

```scheme
(import (scheme base)
        (fibers promises)
        (fibers timers))

(define (read-status resolved rejected fail?)
  "Asynchronously produce status values or reject with a deliberate error.
RESOLVED and REJECTED are host handles supplied by Procedure.call_async."
  (call-with-async-result
   resolved rejected
   (lambda ()
     (sleep 0.01)
     (if fail?
         (error "Status unavailable")
         (values "Ready" 7)))))

read-status
```

A browser host can exercise success and observe failure as follows. These calls
belong inside an async function with `wasmUrl` and `supportUrl` supplied:

```javascript
const runtimeDirectory = new URL(supportUrl, document.baseURI)
  .href.replace(/\/$/, "");
const [readStatus] = await Scheme.load_main(wasmUrl, {
  reflect_wasm_dir: runtimeDirectory
});
const resultValues = await readStatus.call_async(false);
const reflector = resultValues.reflector;
const label = reflector.car(resultValues);
const count = reflector.car(reflector.cdr(resultValues));
// label is "Ready"; count is 7n in the inspected runtime.
await readStatus.call_async(true); // Rejects; the owning boundary handles it.
```

In the inspected runtime, `call-with-async-result` resolves with a Scheme list
of returned values, reflected as pairs, and exact integers become JavaScript
BigInts. The accessor calls above read that representation. This differs from
the online reflection prose describing an array. The
[promise implementation](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/lib/fibers/promises.scm)
and bundled `reflect.js`, verified by execution, determine this example's
contract. Check the selected runtime before adapting it; do not build an
unrequested compatibility layer accepting arbitrary result representations.

`call_async` supplies the first two Scheme arguments. The Scheme procedure must
settle them, for example through `call-with-async-result`; normal return from an
arbitrary synchronous procedure is not this protocol. When using `await` from
`(fibers promises)` for a host Promise, run it in the supported async context
and propagate rejection through the owning operation.

This example intentionally has no native `run-fibers` call. Native Guile's
Fibers package and Hoot's target libraries are related APIs with different
startup arrangements. Use the installed toolchain's implementation and docs when
checking a concrete primitive. A Scheme promise made with `delay` is also a
different mechanism from a JavaScript Promise.

## Contract pitfalls

Consult the
[FFI reference](https://files.spritely.institute/docs/guile-hoot/latest/Foreign-function-interface.html)
and the target implementation for the exact signature being used:

- Match namespace and member spelling in `define-foreign` and `user_imports`. An
  exported Scheme procedure is not automatically a Wasm or JavaScript export.
- A nullable external value is a host-reference value. Check it with the
  supported external-null predicate before using it; do not treat it as an
  ordinary Scheme false value. Declare nullable results when the host can return
  null, such as a failed DOM lookup.
- `define-external-type` makes Scheme-side wrappers distinguishable; wrapping an
  arbitrary external reference alone does not validate its DOM interface.
- For `i32` and `i64`, verify range, signed interpretation, and the JavaScript
  boundary representation. Use an intentional conversion when application
  integers exceed the chosen representation.
- Reflection preserves Scheme types and multiple values. Do not assume every
  list, vector, or mutable string is a native JavaScript array or string.
- Keep external references tied to their owner. Releasing a Scheme local does
  not remove a listener still held by a live DOM object, and a host-held
  callback can retain its runtime and captured instance state.
