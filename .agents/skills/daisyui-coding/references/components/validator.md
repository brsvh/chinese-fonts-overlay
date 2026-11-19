### Validator

The validator class sets an error color or a success color on a form element.
The input validation rules control the color.

[Validator documentation](https://daisyui.com/components/validator/)

#### Class names

- component: `validator`
- part: `validator-hint`

#### Syntax

```html
<label for="reader-email">Email</label>
<input id="reader-email" name="email" type="email" class="input validator"
       aria-describedby="email-hint" required />
<p id="email-hint" class="validator-hint">Enter an email address.</p>
```

#### Rules

- Use the validator with `input`, `select`, and `textarea`.

CSS validation colors and hints do not implement application validation or an
announcement policy. Preserve native constraint validation where applicable, and
report server-side failures as visible, associated text. Unique IDs are required
when this example is repeated.
