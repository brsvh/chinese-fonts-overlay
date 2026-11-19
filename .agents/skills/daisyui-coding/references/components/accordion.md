### Accordion

Use `collapse` radio inputs for a group with at most one selected item. The
selected radio cannot be unchecked by activating it again. If each item must
independently close, consider the native details variant in the
[collapse guide](collapse.md).

[Accordion documentation](https://daisyui.com/components/accordion/)

#### Class names

- component: `collapse`
- part: `collapse-title`, `collapse-content`
- modifier: `collapse-arrow`, `collapse-plus`, `collapse-open`, `collapse-close`

#### Markup contract

```html
<div class="collapse collapse-arrow bg-base-200">
  <input type="radio" name="reading-help" aria-labelledby="help-format" checked />
  <div id="help-format" class="collapse-title">Supported format</div>
  <div class="collapse-content"><p>Read documents as plain text.</p></div>
</div>
<div class="collapse collapse-arrow bg-base-200">
  <input type="radio" name="reading-help" aria-labelledby="help-storage" />
  <div id="help-storage" class="collapse-title">Storage</div>
  <div class="collapse-content"><p>Keep your own copy of each document.</p></div>
</div>
```

Keep the radio and content in the component structure expected by collapse CSS.
Give each input an accessible name, as above. Use a distinct name per
independent group and unique title IDs per instance. Native radio keyboard
behavior applies: Tab enters the group and arrow keys change its selection. This
is a radio-based disclosure, not a complete ARIA button accordion merely because
it looks alike.

`checked` is a Boolean HTML attribute: include it to set the initial default, or
omit it. `checked="false"` is still present and therefore true. Emit the whole
attribute conditionally, not a string placeholder in its value. This is the
rendered HTML contract; dynamic changes use the actual checked property. Only
one item in the group should declare the initial checked state.

Test two groups, accessible names, keyboard selection, and whether the selected
panel actually changes. `collapse-open` and `collapse-close` force visual
states; do not mix them with radios and expect independent selection behavior.

Recheck the rendered output when adapting this structure. The Boolean rule
follows the
[HTML Standard](https://html.spec.whatwg.org/multipage/common-microsyntaxes.html#boolean-attributes).
