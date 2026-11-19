### Tooltip

A tooltip shows a message when the pointer is on an element.

[Tooltip documentation](https://daisyui.com/components/tooltip/)

#### Class names

- component: `tooltip`
- part: `tooltip-content`
- modifier: `tooltip-open`
- placement: `tooltip-top`, `tooltip-bottom`, `tooltip-left`, `tooltip-right`
- alignment: `tooltip-start`, `tooltip-center`, `tooltip-end`
- color: `tooltip-primary`, `tooltip-secondary`, `tooltip-accent`,
  `tooltip-info`, `tooltip-success`, `tooltip-warning`, `tooltip-error`

#### Syntax

```html
<div class="tooltip {MODIFIER}" data-tip="Tooltip text">
  <button type="button" class="btn">Save document</button>
</div>
```

#### Rules

- `{MODIFIER}` is optional. It can include one class name from each modifier,
  placement, and color category.

Keep an accessible name on the control independently of `data-tip`; generated
CSS text is not a dependable naming contract. Essential instructions belong in
visible text or an associated description. Verify focus behavior in the chosen
markup instead of relying only on pointer hover.
