### Progress

Use a progress bar to show task progress or the passage of time.

[Progress documentation](https://daisyui.com/components/progress/)

#### Class names

- component: `progress`
- color: `progress-neutral`, `progress-primary`, `progress-secondary`,
  `progress-accent`, `progress-info`, `progress-success`, `progress-warning`,
  `progress-error`

#### Syntax

```html
<label for="upload-progress">Upload progress</label>
<progress id="upload-progress" class="progress {MODIFIER}" value="50" max="100">50%</progress>
```

#### Rules

- `{MODIFIER}` is optional. It can be one of the color class names.
- For known progress, set `value` to the completed amount and `max` to the
  total. The native default maximum is 1.
- For unknown progress, omit `value`:
  `<progress class="progress" aria-label="Uploading"></progress>`. Do not invent
  a percentage.
- Give the element an accessible name. Content inside `<progress>` is fallback
  text, not its label. Update any separate visible progress text with the value.
