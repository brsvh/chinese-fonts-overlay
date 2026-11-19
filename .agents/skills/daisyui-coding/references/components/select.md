### Select

Use a select component to select a value from a list of options.

[Select documentation](https://daisyui.com/components/select/)

#### Class names

- component: `select`
- style: `select-ghost`
- color: `select-neutral`, `select-primary`, `select-secondary`,
  `select-accent`, `select-info`, `select-success`, `select-warning`,
  `select-error`
- size: `select-xs`, `select-sm`, `select-md`, `select-lg`, `select-xl`

#### Syntax

```html
<label for="reading-layout">Layout</label>
<select id="reading-layout" name="layout" class="select {MODIFIER}">
  <option>Option</option>
</select>
```

#### Rules

- `{MODIFIER}` is optional. It can include one class name from each style,
  color, and size category.
