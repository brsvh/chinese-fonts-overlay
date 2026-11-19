### Radio

Use radio buttons to let the user select one option.

[Radio documentation](https://daisyui.com/components/radio/)

#### Class names

- component: `radio`
- color: `radio-neutral`, `radio-primary`, `radio-secondary`, `radio-accent`,
  `radio-success`, `radio-warning`, `radio-info`, `radio-error`
- size: `radio-xs`, `radio-sm`, `radio-md`, `radio-lg`, `radio-xl`

#### Syntax

```html
<label>
  <input type="radio" name="{name}" value="compact" class="radio {MODIFIER}" />
  Compact layout
</label>
```

#### Rules

- `{MODIFIER}` is optional. It can include one size class name and one color
  class name.
- Replace `{name}` with a name for the radio group.
- Recommendation: Use a unique `name` attribute for each radio-input group. This
  prevents conflicts with other groups on the same page.
