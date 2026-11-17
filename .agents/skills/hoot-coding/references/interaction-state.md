# Owning a sequence of interactions

Read when one mounted Scheme instance handles repeated actions, asynchronous
completion, or disposal. The first source case is a real browser application.
The REPL case concerns session recovery, and the small state owner is an
original adaptation.

## A browser application: Hoot's todo demo

In
[hoot-ffi-demo b98bd924](https://codeberg.org/spritely/hoot-ffi-demo/src/commit/b98bd924bf289adfc6d0cf2a63f64be0fa5bcf4c/todo.scm),
follow `template`, `render`, `virtual-dom-render`, and
`procedure->external/cached`; `todo.js` supplies the DOM and localStorage
imports. This historical demo uses an older Hoot API. Its loader and foreign
signatures are not a template for the selected Hoot version.

The application keeps task records and the previous virtual tree in Scheme. An
input event changes that state, writes storage, and renders the next tree.
`render` publishes the new virtual tree after patching. The JavaScript imports
are thin DOM operations rather than a second implementation of task policy. This
is a concrete example of browser behavior owned by Scheme; a small page does not
need to adopt its virtual DOM implementation.

Three details matter when repeating an interaction:

- Rebuilding `template` creates new Scheme listener closures. Attribute updates
  remove the old listener before installing the new one. The weak-key cache
  returns the same external function for the same Scheme procedure, so removal
  uses the identity originally registered. Re-converting without that contract
  can leave duplicate listeners. Check the current runtime's conversion API; a
  cache is not mandatory when the owner already retains the exact wrapper.
- A checkbox's live state comes from its `checked` property. The demo handles it
  separately from string attributes. Removing a `checked` attribute is not the
  general operation for unchecking a user-modified control. Likewise, setting
  the entry's live `value` clears the input after adding a task.
- The renderer reuses children by position, not stable task keys. Removing the
  first task can reuse its node for a different task. Listener replacement
  updates the action, but preservation of focus, selection, and other local
  element state is a separate requirement. Test the focused middle item when
  list identity matters; do not promise keyed reconciliation from this demo.

The demo has explicit limits. `getItem` maps missing or empty storage to `"()"`,
then Scheme reads task data without a full schema. Storage denial, malformed
stored data, and write failure have no recovery policy. Mutating a task before a
failing storage write can leave model, stored value, and rendered view
disagreeing. Decide whether persistence failure rolls back the action or keeps
an unsaved state and reports it; test that chosen policy. A load-time callback
is not a repeated mount/dispose protocol, and subtree removal does not prove
cancellation of unrelated timers or Promises.

A focused adaptation tests add, toggle twice, remove the first of two tasks, and
dispatch again after several renders. Assert that one event causes one model
update. Then inject malformed storage and a throwing storage setter. These are
proposed application regressions derived from inspected code; the historical
demo was not rebuilt or certified against current Hoot.

## Hoot's REPL separates session lifetime from one failed action

At
[Hoot 16914de6](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534),
follow `repl/repl.scm` into `lib/hoot/repl.scm:spawn-repl` and `run-repl`. The
outer entry installs the session's input/output streams and owns one
asynchronous result. Inside it, the read/evaluate/print loop owns successive
interactions and an explicit REPL environment stack.

`repl-meta-eval` reports an ordinary command failure but re-raises the distinct
quit exception. `run-repl` treats EOF, a recoverable read failure, and a value
to evaluate differently. A read failure on a closed input port ends the loop;
blindly retrying would not restore the resource. Evaluation errors can enter a
debugging environment, while leaving an environment restores the previous one.

The transferable decisions are where an action can recover and which events end
the owner. Keep the session's completion separate from completion of one
operation. Do not catch disposal or termination as an ordinary user-visible
failure and continue using released resources. A page enhancement does not need
the REPL's evaluator, prompt stack, or debugger to apply those decisions.

## Start with one explicit action policy

For a single button, decide whether an action while busy is ignored, queued, or
replaces the old action. Use one policy justified by the interaction; parallel
work and a queue are not implied by the ability to start a Promise. For a
single-flight action, a closure can own busy/disposed state without a component
registry. For replacement, identify the active operation so a late result cannot
overwrite it.

Here is an original small owner for one in-flight operation. The returned
procedures begin work, settle it, dispose the owner, and inspect its phase. It
assumes callbacks execute serially in one Hoot host instance. It manages logical
state only; it neither cancels a Promise nor unregisters listeners.

```scheme
(import (scheme base))

(define (make-action-owner)
  "Return begin, settle, dispose, and phase procedures for one action.
A token identifies accepted work. Disposal rejects later state updates."
  (let ((phase 'idle)
        (active-token #f))
    (define (begin!)
      "Accept one action when available, returning its identity or #f."
      (if (memq phase '(pending disposed))
          #f
          (let ((token (list 'operation)))
            (set! active-token token)
            (set! phase 'pending)
            token)))
    (define (settle! token outcome)
      "Publish a current pending TOKEN's success or failure; report acceptance."
      (unless (memq outcome '(succeeded failed))
        (error "Invalid action outcome" outcome))
      (if (and (eq? phase 'pending) (eq? token active-token))
          (begin
            (set! active-token #f)
            (set! phase outcome)
            #t)
          #f))
    (define (dispose!)
      "Invalidate pending work; repeated disposal is harmless."
      (set! active-token #f)
      (set! phase 'disposed))
    (define (current-phase)
      "Return the owner's current phase."
      phase)
    (values begin! settle! dispose! current-phase)))
```

Call `begin!` before starting the host action. Only an accepted settlement may
change the visible outcome. Run the host call and its await through the
[Promise contract](host-promises.md); failure while starting is also a failed
action. Always observe host rejection, even when disposal causes its state
update to be ignored. Keep cleanup of listeners/timers with their actual owner.

A single boolean can suffice when no outcome display or stale completion is
possible. Keep the token only where identity matters; a replaceable action would
need a deliberately different begin policy. Do not share this mutable closure
across unrelated runtime instances.

## Page restoration is not permanent disposal

The retained Copy link fixture keeps its instance and listeners on `pagehide`
when `event.persisted` is true. On a non-persisted departure it disposes the
instance and disables the button. Its listener is not one-shot: a cached
departure can precede a later permanent departure.

This policy fits a small action without external connections to suspend. Owners
that must release resources while hidden need a corresponding restoration path.
Do not permanently dispose a live control on every `pagehide`, or mount a second
instance over the retained one on `pageshow`. The browser may discard a cached
document without another cleanup callback; do not depend on that event for
durable writes or server-side release.

[Browser lifecycle guidance](https://web.dev/articles/bfcache) distinguishes the
intent to cache at `pagehide` from an actual restoration, identified by
`pageshow.persisted`. The retained fixture originally left an enabled but inert
button after a real Chrome back navigation. This is a local regression case,
separate from the historical Hoot demo above.

## Test the interaction sequence

Execute the following sequences through the returned operations:

- Begin, attempt a duplicate begin, settle successfully, then begin again.
- Fail an accepted action, retry, then deliver the old result after retry.
- Begin, dispose, then deliver success and failure; neither revives the owner.
- Dispose twice and attempt another begin.

These expose state ownership beyond an isolated Promise success test. Execute
the same pure policy in native Guile and compiled Hoot if it is shared. A Node
host proves compiled state transitions, not browser input, permissions, or
layout. Browser fault injection and cross-skill test handoffs are outside this
reference.

The
[current browser fixture](verification-examples.md#retained-current-runtime-browser-probe)
extracts this policy rather than copying it into another implementation. Its
Scheme action exercises the policy through suspended host work and visible
outcomes. Source revisions above remain historical evidence, while that fixture
records the selected current toolchain's behavior.
