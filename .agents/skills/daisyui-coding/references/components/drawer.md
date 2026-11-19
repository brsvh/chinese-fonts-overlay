### Drawer

A drawer lays out main content and a sidebar. Decide whether the sidebar is
ordinary navigation or an overlay that makes the background unavailable.

[Drawer documentation](https://daisyui.com/components/drawer/)

#### Class names

- component: `drawer`
- part: `drawer-toggle`, `drawer-content`, `drawer-side`, `drawer-overlay`,
  `drawer-button`
- placement: `drawer-end`
- modifier: `drawer-open`
- variant: `is-drawer-open:`, `is-drawer-close:`

#### Checkbox-owned layout

```html
<div class="drawer lg:drawer-open">
  <input id="entry-navigation" type="checkbox" class="drawer-toggle"
         aria-label="Show navigation" />
  <div class="drawer-content">
    <label for="entry-navigation" class="btn drawer-button lg:hidden">
      Show navigation
    </label>
    <main><!-- Page content --></main>
  </div>
  <div class="drawer-side">
    <label for="entry-navigation" aria-label="Close navigation"
           class="drawer-overlay"></label>
    <nav aria-label="Main navigation" class="bg-base-200 min-h-full w-80 p-4">
      <ul class="menu">
        <li><a href="/">Home</a></li>
        <li><a href="/entries">Entries</a></li>
      </ul>
    </nav>
  </div>
</div>
```

Use unique IDs for independent instances. Match the label's `for` to the actual
checkbox. The visually hidden checkbox remains a native keyboard control in the
closed/mobile layout; it is not `input type="hidden"`. In the
[inspected CSS](https://github.com/saadeghi/daisyui/blob/dd0a94a20ae35c7587017766cef9f0c109ff819b/packages/daisyui/src/components/drawer.css),
its focus-visible state draws an outline on the `drawer-content` label. Preserve
that relationship if relying on this feedback. `drawer-open` hides the toggle
when the sidebar is persistent.

A label styled as `btn` still toggles its associated checkbox; it is not a
native button. The overlay label gives pointer users a closing target, but
keyboard closing and focus placement need deliberate verification. Do not claim
modal behavior from the CSS: background inertness, Escape handling, focus
containment/return, and synchronization at a responsive breakpoint are separate
interaction decisions. See the real application example in
[Composition](../composition.md#a-navigation-drawer-has-different-roles-at-different-widths)
when these behaviors are needed.

Navigation uses real links; actions use buttons with the appropriate type. If
labels disappear in an icon-only state, retain each control's accessible name
independently of a hover tooltip. Test narrow/wide transitions, focus
visibility, and long navigation labels before adopting the layout.
