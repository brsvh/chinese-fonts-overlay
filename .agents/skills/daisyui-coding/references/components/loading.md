### Loading

Use the loading component to show an animation while a process runs.

[Loading documentation](https://daisyui.com/components/loading/)

#### Class names

- component: `loading`
- style: `loading-spinner`, `loading-dots`, `loading-ring`, `loading-ball`,
  `loading-bars`, `loading-infinity`
- size: `loading-xs`, `loading-sm`, `loading-md`, `loading-lg`, `loading-xl`

#### Syntax

```html
<span role="status"><span class="loading {MODIFIER}" aria-hidden="true"></span> Loading results</span>
```

#### Rules

- `{MODIFIER}` is optional. It can include one style class name and one size
  class name.
- Keep the status container stable and update its message when work settles. Do
  not leave stale loading text after success or failure, or announce the
  animation repeatedly.
