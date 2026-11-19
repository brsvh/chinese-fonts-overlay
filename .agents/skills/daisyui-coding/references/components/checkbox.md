### Checkbox

Use a checkbox to select or deselect a value.

[Checkbox documentation](https://daisyui.com/components/checkbox/)

#### Class names

- component: `checkbox`
- color: `checkbox-primary`, `checkbox-secondary`, `checkbox-accent`,
  `checkbox-neutral`, `checkbox-success`, `checkbox-warning`, `checkbox-info`,
  `checkbox-error`
- size: `checkbox-xs`, `checkbox-sm`, `checkbox-md`, `checkbox-lg`,
  `checkbox-xl`

#### Syntax

```html
<label><input type="checkbox" class="checkbox {MODIFIER}" /> Include notes</label>
```

#### Rules

- `{MODIFIER}` is optional. It can include one color class name and one size
  class name.
- For select-all, derive `checked` and `indeterminate` from the actual group
  selection. Set `indeterminate` through the DOM property; an HTML attribute of
  that name does not initialize it. Include options hidden by a collapsed list
  when the action means the entire group, and follow the application's defined
  behavior for an empty selection and reset.
