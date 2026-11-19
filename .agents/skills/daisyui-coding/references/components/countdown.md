### Countdown

A countdown gives a transition effect when a number changes from 0 through 999.

[Countdown documentation](https://daisyui.com/components/countdown/)

#### Class names

- component: `countdown`

#### Syntax

```html
<span class="countdown">
  <span style="--value:{number};">number</span>
</span>
```

#### Rules

- The `--value` CSS variable and the text must contain a number from 0 through
  999\.
- The interaction owner updates the span text and `--value` together.
- Include meaningful units in readable text. Do not make every timer tick a live
  announcement; announce meaningful milestones or completion when needed.
  Decorative digit transitions can be hidden from assistive technology while
  equivalent text remains available.
