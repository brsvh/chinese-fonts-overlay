---
name: daisyui-coding
description: >-
  Write, review, and refactor interfaces using daisyUI components, semantic
  colors, themes, and Tailwind utilities. Use for daisyUI integration, markup,
  styling, and build configuration, including statically generated HTML and
  Scheme/SXML renderers.
metadata:
  daisyui-reference: 5.7.39
  tailwind-reference: 4.3.4
---

# daisyUI Coding

The reference baseline is daisyUI 5.7.39 with Tailwind CSS 4.3.4; see
[version alignment](references/versions.md) for the pinned official skill and
source revision. Read the target project's applicable instructions and discover
its actual versions, CSS entry points, prefixes, build commands, and browser
requirements. An older installation requires its matching documentation; using
this skill does not authorize an upgrade. Check version-sensitive features
against the matching release's sources or documentation. A reference baseline is
evidence, not a requirement to change another project's dependency pins.

Follow the project's rendering, interaction, localization, and documentation
conventions. Examples in this skill use English; they do not require English
product text. Keep project-specific themes, paths, and business rules in the
project rather than making them prerequisites for reusing this skill.

Resolve bundled references relative to this skill's installed directory. Use
companion renderer, language, or build skills when relevant and available; do
not assume another skill, framework, package manager, or Nix installation.

## Select relevant references

- For initial adoption, CSS builds, source detection, or generated templates,
  read [build integration](references/build-integration.md). It covers both
  package-manager and standalone builds, including Scheme/Hoot and optional
  Nix/Autotools integration.
- For page composition, control selection, or responsive behavior, read
  [Composition cases](references/composition.md).
- For a named component, read its guide through the
  [component index](references/components.md). When the choice is unclear,
  compare the candidates that fit the required behavior and layout.
- For color or theme changes, read
  [colors and themes](references/colors-and-themes.md).
- For plugin options, theme selection, prefixes, or included modules, read
  [configuration](references/configuration.md).

Load only the references relevant to the task. Component examples describe
markup contracts; adapt them to the project's renderer and event bindings.

## Components and styling

- Use the component class, required child parts, and applicable modifiers from
  its guide. Preserve required element relationships and state attributes.
- Treat `component`, `part`, `color`, `style`, `behavior`, `size`, `placement`,
  `direction`, and `modifier` as documentation labels, not literal classes.
  Tailwind variants use the form `variant:utility-class`.
- Use classes supported by the project's versions. Account for configured
  prefixes when applying examples.
- Preserve the intended design. Use component variants, theme variables, and
  local styling to express it; adopting daisyUI does not require adopting a
  built-in theme, default spacing, or card layout.
- Add Tailwind utilities for spacing, layout, sizing, and local adjustments. If
  no component fits, compose suitable utilities. Use custom CSS when the
  component API and utilities do not express the required behavior clearly.
- Resolve specificity and cascade conflicts deliberately. A trailing `!` on a
  Tailwind utility, such as `px-10!`, is a targeted fallback, not a default.
- Use responsive utilities where the layout needs to change with available
  space. Avoid introducing fonts or external placeholder services solely to
  restyle an existing component.

For an intentional shared component customization, use the existing CSS entry
point and Tailwind's `@utility` directive:

```css
@utility btn {
  @apply rounded-full;
}
```

Keep local adjustments on the relevant elements; a shared customization affects
all uses of that component in the compiled stylesheet.

## Colors and visual tokens

- Prefer semantic colors and their matching content colors so components can
  follow the active theme. Check contrast in the themes the project supports.
- Use surface colors and emphasis consistently with the interface's hierarchy.
  The number of primary-colored elements is a design decision, not a fixed rule.
- Use theme radius utilities such as `rounded-box`, `rounded-field`, and
  `rounded-selector` when appropriate. `glass` supplies the glass effect.
- Use documented component variables for targeted changes, such as `--value` and
  `--digits` for countdown, or `--size` and `--thickness` for radial progress.

## Semantics and interaction

- Choose HTML elements for their behavior, provide accessible names and labels,
  and preserve keyboard operation and visible focus. Styling alone does not
  supply interaction or make an element disabled.
- Boolean HTML attributes such as checked, disabled, selected, and required are
  true when present, even with a value of "false". Omit false attributes; ARIA
  attributes such as aria-expanded have different value semantics. Repeated
  components need unique IDs, correctly scoped radio names, and labels.
- Preserve the distinction between native behavior and library-specific
  interactions. Keep focus, dismissal, and state handling consistent with the
  chosen component and the project's event system.
- For Scheme/SXML output, preserve the rendered HTML structure, attributes, and
  class names. Wire behavior through the existing Scheme/Hoot host interfaces
  rather than copying inline JavaScript handlers automatically.
- Keep complete class names visible to the stylesheet scanner, including classes
  used only after an interaction. Use explicit state-to-class mappings or a
  narrowly scoped source declaration rather than concatenating fragments.

## Verification

Run the relevant stylesheet build and existing checks for implementation
changes. Inspect changed markup as rendered, including affected responsive
layouts, themes, keyboard behavior, and interactive states. Verify observable
behavior with the smallest useful coverage; avoid tests that merely assert class
strings or mirror internal helpers, and do not add a test framework for a
styling-only edit. Report the checks performed and distinguish successful CSS
compilation from actual visual and interaction verification.
