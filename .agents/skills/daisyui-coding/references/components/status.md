### Status

A status is a small icon that shows the current state of an element. Example
states are online, offline, and error.

[Status documentation](https://daisyui.com/components/status/)

#### Class names

- component: `status`
- color: `status-neutral`, `status-primary`, `status-secondary`,
  `status-accent`, `status-info`, `status-success`, `status-warning`,
  `status-error`
- size: `status-xs`, `status-sm`, `status-md`, `status-lg`, `status-xl`

#### Syntax

```html
<span><span class="status {MODIFIER}" aria-hidden="true"></span> Online</span>
```

#### Rules

- `{MODIFIER}` is optional. It can include one color class name and one size
  class name.
- Express the state in text as well as color. Use a live region only if a
  changing state needs announcement; a static decorative dot does not need one.
