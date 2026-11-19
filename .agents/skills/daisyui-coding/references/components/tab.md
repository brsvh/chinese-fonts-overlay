### Tab

Use tab styling for navigation or local panel selection according to the actual
interaction. [Tab documentation](https://daisyui.com/components/tab/)

#### Class names

- component: `tabs`
- part: `tab`, `tab-content`
- style: `tabs-box`, `tabs-border`, `tabs-lift`
- size: `tabs-xs`, `tabs-sm`, `tabs-md`, `tabs-lg`, `tabs-xl`
- modifier: `tab-active`, `tab-disabled`
- placement: `tabs-top`, `tabs-bottom`

#### Navigation

```html
<nav aria-label="Sections" class="tabs tabs-border">
  <a class="tab" href="/overview" aria-current="page">Overview</a>
  <a class="tab" href="/details">Details</a>
</nav>
```

These are navigation links, so they do not need `tablist` or `tab` roles. Use
the application's real URLs and its selected version's active styling.

#### Native radio selection

```html
<fieldset class="tabs tabs-box">
  <legend class="sr-only">View</legend>
  <input type="radio" name="sample-view" class="tab"
         aria-label="Summary" checked />
  <div class="tab-content p-4">Summary content</div>
  <input type="radio" name="sample-view" class="tab"
         aria-label="Details" />
  <div class="tab-content p-4">Detailed content</div>
</fieldset>
```

Keep each panel immediately after its control under the supported CSS contract.
Give each independent instance its own radio group name. Verify content access
and keyboard behavior for the chosen representation; this is native radio
selection, not a complete ARIA tabs widget.

#### Button-based tabs

Use button tabs only with an interaction that maintains selection, tab/panel
relationships, focus movement, and keyboard behavior. Styling and assigning
roles alone do not implement these. `tab-disabled` is visual/pointer styling;
use the control's native disabled property where appropriate and handle any
remaining keyboard/link behavior deliberately.
