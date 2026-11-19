### Swap

Use the swap component to change the visibility of two elements. Control the
swap with a checkbox or a class name.

[Swap documentation](https://daisyui.com/components/swap/)

#### Class names

- component: `swap`
- part: `swap-on`, `swap-off`, `swap-indeterminate`
- modifier: `swap-active`
- style: `swap-rotate`, `swap-flip`

#### Syntax

Checkbox:

```html
<label class="swap {MODIFIER}">
  <input type="checkbox" aria-label="Enable notifications" />
  <div class="swap-on" aria-hidden="true">{content when active}</div>
  <div class="swap-off" aria-hidden="true">{content when inactive}</div>
</label>
```

Class name:

```html
<div class="swap {MODIFIER}">
  <div class="swap-on">{content when active}</div>
  <div class="swap-off">{content when inactive}</div>
</div>
```

#### Rules

- `{MODIFIER}` is optional. It can include one modifier class name and one style
  class name.
- Let daisyUI visually style the native checkbox; do not add `hidden` or
  `display: none` to the interactive control. Give it a stable name and keep its
  checked state and visible focus usable by keyboard.
- Class-controlled content is display only unless an actual keyboard-operable
  control updates `swap-active` and exposes the same state. Decorative icons may
  use `aria-hidden`; meaningful text must remain available.
- To show content when the checkbox is indeterminate, use the
  `swap-indeterminate` class.
