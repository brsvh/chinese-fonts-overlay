### Collapse

Use a disclosure for content that the user opens and closes.

[Collapse documentation](https://daisyui.com/components/collapse/)

#### Class names

- component: `collapse`
- part: `collapse-title`, `collapse-content`
- modifier: `collapse-arrow`, `collapse-plus`, `collapse-open`, `collapse-close`

#### Native disclosure

```html
<details class="collapse collapse-arrow bg-base-200">
  <summary class="collapse-title">More information</summary>
  <div class="collapse-content"><p>Additional content.</p></div>
</details>
```

`summary` supplies the native toggle. Keep it as a direct child and give it a
meaningful name. Keyboard activation changes the `details` element's open state.
Do not add a separate static `aria-expanded` that can disagree with that state.

#### Other mechanisms have different contracts

- A focusable `div` with `tabindex="0"` uses focus/focus-within styling. It can
  close when focus leaves; it is not a persistent disclosure button or a
  complete expanded/collapsed accessibility state.
- A first-child checkbox can own checked state. Give that actual control an
  accessible name and preserve keyboard access; a nearby title alone need not
  label it. Radio variants share native grouping by `name`.
- `collapse-open` and `collapse-close` force appearance. They do not implement a
  keyboard action, state synchronization, or naming.

The
[inspected CSS in v5.7.39](https://github.com/saadeghi/daisyui/blob/dd0a94a20ae35c7587017766cef9f0c109ff819b/packages/daisyui/src/components/collapse.css)
selects `[open]`, focus, and checked inputs separately. Choose one state owner
and test opening, closing, and moving focus into the content. Do not combine
mechanisms merely to make a screenshot look open.
