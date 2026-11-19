### Toast

A toast is a wrapper that stacks elements in a corner of the page.

[Toast documentation](https://daisyui.com/components/toast/)

#### Class names

- component: `toast`
- placement: `toast-start`, `toast-center`, `toast-end`, `toast-top`,
  `toast-middle`, `toast-bottom`

#### Syntax

```html
<div class="toast {MODIFIER}">{CONTENT}</div>
```

#### Rules

- `{MODIFIER}` is optional. Combine one horizontal and one vertical placement
  where needed.
- `toast` controls placement only. For ordinary asynchronous feedback, create a
  stable `role="status"` region before updating its message. Reserve
  `role="alert"` for urgent interruption.
- Keep necessary recovery information available and give dismiss controls
  meaningful names. Do not move focus merely to announce success.
