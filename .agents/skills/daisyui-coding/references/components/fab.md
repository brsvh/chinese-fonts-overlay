### FAB

A floating action button places an action near a screen corner. Use one action
when a menu is unnecessary.

[FAB documentation](https://daisyui.com/components/fab/)

#### Class names

- component: `fab`
- part: `fab-close`, `fab-main-action`
- modifier: `fab-flower`

#### One action

```html
<div class="fab">
  <button type="button" class="btn btn-primary">Create entry</button>
</div>
```

A visible text label is the simplest name. An icon-only action needs a name such
as `aria-label="Create entry"`; a visual tooltip is not a substitute.

#### Focus-revealed action group

This fragment illustrates the stylesheet's structure. The trigger must remain
its first direct child, and `tabindex` participates in CSS selection even on a
native button:

```html
<div class="fab">
  <button type="button" tabindex="0"
          class="btn btn-primary">Entry actions</button>
  <button type="button" class="btn">Create entry</button>
  <button type="button" class="btn">Import entries</button>
</div>
```

In v5.7.39,
[`fab.css`](https://github.com/saadeghi/daisyui/blob/dd0a94a20ae35c7587017766cef9f0c109ff819b/packages/daisyui/src/components/fab.css)
reveals subsequent children using `:focus-within`. `[tabindex]:first-child` is
styled as the trigger. `fab-flower` changes placement, not semantics. This is
focus-driven disclosure, not a click-toggle state machine. A bare
`div role="button"` does not acquire native Space/Enter activation.

For an actual expandable widget, define its state announcement and keyboard
contract, including how it closes and where focus goes. Do not add a permanently
false `aria-expanded` while CSS can reveal the actions. Do not advertise menu
roles without implementing their keyboard behavior. If the desired behavior is
persistent open/close, use a mechanism that owns that state rather than relying
on focus styling incidentally.

The `fab-close` and `fab-main-action` classes position replacement content. A
close-looking span does not implement a close action. Use a named native button
and implement its focus/state effect; the class alone does neither. Verify that
revealed actions can be reached and that controls do not cover page content at
narrow widths. CSS inspection alone is not an accessibility certification.
