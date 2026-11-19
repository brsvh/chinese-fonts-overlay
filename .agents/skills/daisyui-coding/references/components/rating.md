### Rating

A rating is a set of radio buttons that lets the user give a rating.

[Rating documentation](https://daisyui.com/components/rating/)

#### Class names

- component: `rating`
- modifier: `rating-half`, `rating-hidden`
- size: `rating-xs`, `rating-sm`, `rating-md`, `rating-lg`, `rating-xl`

#### Syntax

```html
<fieldset>
  <legend>Rating</legend>
  <div class="rating {MODIFIER}">
    <input type="radio" name="rating-1" value="1" aria-label="1 star" class="mask mask-star" />
    <input type="radio" name="rating-1" value="2" aria-label="2 stars" class="mask mask-star" />
  </div>
</fieldset>
```

For a read-only rating, expose one textual value; the stars are decoration:

```html
<div class="rating" role="img" aria-label="2 out of 3 stars">
  <div class="mask mask-star" aria-hidden="true"></div>
  <div class="mask mask-star" aria-hidden="true"></div>
  <div class="mask mask-star opacity-20" aria-hidden="true"></div>
</div>
```

#### Rules

- `{MODIFIER}` is optional. It can include one modifier class name and one size
  class name.
- Recommendation: Use a unique `name` attribute for each rating-input group.
  This prevents conflicts with other ratings on the same page.
- A `rating-hidden` reset input still needs a name such as "No rating" and a
  defined value. Verify its keyboard focus remains perceivable; a visible reset
  control can be clearer.
- Keep interactive choices as native radios with individual names and a group
  legend. Do not use `aria-current` as a substitute for the selected radio
  state.
