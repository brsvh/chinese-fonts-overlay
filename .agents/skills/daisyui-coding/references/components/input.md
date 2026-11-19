### Input

Use a text input as a simple input field.

[Input documentation](https://daisyui.com/components/input/)

#### Class names

- component: `input`
- style: `input-ghost`
- color: `input-neutral`, `input-primary`, `input-secondary`, `input-accent`,
  `input-info`, `input-success`, `input-warning`, `input-error`
- size: `input-xs`, `input-sm`, `input-md`, `input-lg`, `input-xl`

#### Syntax

```html
<label for="reader-name">Reader name</label>
<input id="reader-name" name="reader-name" type="text" class="input {MODIFIER}" />
```

#### Rules

- `{MODIFIER}` is optional. It can include one class name from each style,
  color, and size category.
- Use it for text-like fields such as text, password, or email. Choose the
  dedicated checkbox, radio, range, or file-input component for those controls.
- If the input contains more than one element, use the `input` class on the
  parent element.
