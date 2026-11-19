### Button

Use buttons to start actions.

[Button documentation](https://daisyui.com/components/button/)

#### Class names

- component: `btn`
- color: `btn-neutral`, `btn-primary`, `btn-secondary`, `btn-accent`,
  `btn-info`, `btn-success`, `btn-warning`, `btn-error`
- style: `btn-outline`, `btn-dash`, `btn-soft`, `btn-ghost`, `btn-link`
- behavior: `btn-active`, `btn-disabled`
- size: `btn-xs`, `btn-sm`, `btn-md`, `btn-lg`, `btn-xl`
- modifier: `btn-wide`, `btn-block`, `btn-square`, `btn-circle`

#### Syntax

```html
<button type="button" class="btn {MODIFIER}">Button</button>
```

#### Rules

- `{MODIFIER}` is optional. It can include one class name from each color,
  style, behavior, size, and modifier category.
- You can use `btn` on HTML elements such as `<button>`, `<a>`, and `<input>`.
- A `btn` element can have an icon before or after the text.
- For an unavailable native action, use
  `<button type="button" class="btn" disabled>Save</button>`. `btn-disabled`
  supplies appearance; `aria-disabled="true"` supplies a semantic state. Neither
  alone blocks event handlers or navigation. `tabindex="-1"` changes sequential
  focus, not whether the action can run.
- Use an anchor with a real `href` for navigation. If a custom unavailable
  control must remain discoverable, its owning interaction must suppress every
  activation path and expose the disabled state. Prefer native disabled buttons
  when that contract fits; do not turn navigation into a button by adding a
  role.
- Set `type="button"` for non-submit actions inside forms. Use `type="submit"`
  only when submission is intended. Icon-only buttons need an accessible name;
  decorative icons should not repeat it.
- Check disabled and busy behavior with both pointer and keyboard input. Busy
  presentation must retain the action's name and the chosen repeat policy.
