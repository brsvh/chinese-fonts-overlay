### Range

Move a range-slider handle to select a value.

[Range documentation](https://daisyui.com/components/range/)

#### Class names

- component: `range`
- color: `range-neutral`, `range-primary`, `range-secondary`, `range-accent`,
  `range-success`, `range-warning`, `range-info`, `range-error`
- size: `range-xs`, `range-sm`, `range-md`, `range-lg`, `range-xl`
- direction: `range-vertical` (vertical slider)

#### Syntax

```html
<label for="volume">Volume</label>
<input id="volume" type="range" min="0" max="100" value="40" class="range {MODIFIER}" />
```

#### Rules

- `{MODIFIER}` is optional. It can include one color class name and one size
  class name.
- For a vertical slider, use `range-vertical`.
- Set bounds and `step` for the domain; the native defaults are 0, 100, and 1.
  Keep the native control keyboard-operable.
- If the numeric value is not meaningful by itself, supply and update
  `aria-valuetext`, such as a named preset.
