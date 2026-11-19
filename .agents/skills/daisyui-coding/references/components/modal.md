### Modal

Choose modal dialog or non-modal disclosure by behavior before choosing box
styling. [Modal documentation](https://daisyui.com/components/modal/)

#### Class names

- component: `modal`
- part: `modal-box`, `modal-action`, `modal-backdrop`, `modal-toggle`
- modifier: `modal-open`
- placement: `modal-top`, `modal-middle`, `modal-bottom`, `modal-start`,
  `modal-end`

#### Native modal dialog

```html
<button type="button" class="btn" data-open-dialog="sample-dialog">
  Open details
</button>
<dialog id="sample-dialog" class="modal" aria-labelledby="sample-title">
  <div class="modal-box">
    <h2 id="sample-title" class="text-lg font-bold">Details</h2>
    <p>Review the information before closing this dialog.</p>
    <form method="dialog" class="modal-action">
      <button class="btn" value="close">Close</button>
    </form>
  </div>
</dialog>
```

`data-open-dialog` is an illustrative binding hook, not daisyUI behavior. The
application must connect it to the dialog's `showModal()` operation through its
event system. Do not expose an apparently working opener before that binding is
ready. A native form with `method="dialog"` supplies a close action. Add a
supported backdrop form only when outside-click dismissal is intended.

Give every instance unique IDs and an accessible name. Verify focus on open,
keyboard dismissal, focus restoration, and any explicit initial-focus policy.
The class `modal-open` alone does not create native modal focus behavior.

#### Non-modal disclosure

A popover can share the visual classes while preserving non-modal behavior:

```html
<button type="button" class="btn" popovertarget="sample-popover">
  More information
</button>
<div id="sample-popover" class="modal" popover>
  <div class="modal-box">
    <p>Additional information</p>
    <button type="button" class="btn" popovertarget="sample-popover"
            popovertargetaction="hide">Close</button>
  </div>
</div>
```

Use the project's supported browser contract for popover. It is not a substitute
for modal behavior where that is required. Checkbox and anchor-driven legacy
patterns may be maintained where already used, but require their own focus,
naming, dismissal, and keyboard behavior; do not choose them solely to avoid
implementing the intended interaction.
