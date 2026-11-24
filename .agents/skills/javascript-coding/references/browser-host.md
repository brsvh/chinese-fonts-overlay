# Browser and host interfaces

Read for DOM interactions, asynchronous navigation, browser resources, or
JavaScript adapters to Scheme/Wasm. Use the project's rendering and interaction
boundaries; this reference does not move application policy between languages.

## DOM and resource ownership

Assign listeners, observers, timers, animation frames, and pending requests to
their actual owner: a document, view, or action. Avoid registering them again
when an existing owner is reactivated. Release them when that owner is disposed.
A `WeakMap` does not disconnect an observer or remove a listener held elsewhere.

Use stable handler references or a supported listener signal when teardown is
needed. Define initialization and disposal behavior so repeated calls do not
duplicate effects. Keep retained views and destroyed views distinct; a
temporarily detached node may still be owned by a live view.

Use `textContent` for plain text. Create nodes or use the existing trusted
rendering path for markup. Escaping text, validating a URL scheme, and escaping
a selector are different operations. Use `CSS.escape` for dynamic selector
components and `URL`/`URLSearchParams` for URL structure. When embedding JSON in
HTML, follow the renderer's HTML-safe serialization contract.

Preserve native links, controls, labels, keyboard operation, and focus. Match
boolean properties and attributes to their actual semantics; an attribute whose
text is `false` may still enable a boolean HTML state. ARIA state is a separate
contract and should agree with the control's behavior.

When a script moves, check how the HTML loads it and how it locates its own
assets. Relative imports in a module resolve against its URL. Relative URLs in
DOM attributes can depend on the current document or its base element.

Keep DOM reads and writes organized when layout cost matters. An animation frame
callback is not proof that a paint or font load has completed. Await the
specific readiness condition and retain the project's fallback on failure.

## Asynchronous views and navigation

Give each request a captured owner or generation. Recheck ownership before
publishing results, including error messages, loading flags, and cleanup that
could affect a newer request. Aborting a replaced request helps release work,
but the ownership check is still needed when cancellation is unsupported or
arrives after completion.

Separate an action's acceptance, in-progress state, and settled outcome. Report
success after completion. A disabled button prevents some new input; it neither
cancels an accepted operation nor makes its eventual result current. Keep
failure, cancellation, and a successful empty result distinguishable where the
interface needs them.

When enhancing navigation, preserve normal handling for external links,
downloads, non-primary clicks, modifiers, and alternate targets. Keep browser
history, fragments, focus, and scroll restoration coherent. On enhancement
failure, retain or follow the original destination according to the existing
navigation contract.

For APIs requiring user activation, start the operation from the accepted user
action before unrelated asynchronous work. Feature detection does not prove
permission or successful execution. Handle the actual result and preserve a
usable fallback. Repeated or delayed actions must not claim an external effect
was cancelled when only its local result was discarded.

## Scheme/Wasm adapters

Use `hoot-coding` when changing Hoot imports, reflection, or compiled Scheme.
Verify both sides of the actual signature and load the matching runtime assets.
Keep JavaScript adapters focused on host operations and representation changes;
leave application decisions in the layer assigned by the project.

Specify numeric and boolean representations, missing values, strings, foreign
references, and callback lifetimes at the boundary. Do not assume that Scheme
false, JavaScript false, null, and zero are interchangeable, or that a reflected
Scheme collection is a JavaScript array. Follow the selected runtime's exact
conversion rules.

Distinguish a synchronous return, a returned Promise, and completion callbacks.
An `async` adapter converts a synchronous host throw into rejection when the
interface expects a Promise. For callback interfaces, route both synchronous
host errors and asynchronous rejection to the intended failure path, and deliver
one terminal outcome per accepted operation.

With `promise.then(success, failure)`, an exception in `success` rejects the
returned Promise; the sibling `failure` handler does not catch it. Own that
returned Promise too. Conversely, a catch after `success` must not report a
second operation outcome merely because the success callback itself failed. Keep
host-operation failure and callback failure distinct.

Verify successful completion, rejection, synchronous host throws, and delayed
completion through the real bridge. Include repeated activation or disposal when
lifetimes change. Compilation alone cannot establish settlement behavior or
browser permission handling.
