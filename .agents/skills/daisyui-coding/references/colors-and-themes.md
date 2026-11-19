# daisyUI Colors and Themes

Read this reference when choosing semantic colors, changing themes, or editing
theme variables. See [configuration](configuration.md) for enabling themes and
selecting their default roles.

## Semantic colors

| Color                  | Role                                      | Matching foreground |
| ---------------------- | ----------------------------------------- | ------------------- |
| `base-100`             | Main page or component surface.           | `base-content`      |
| `base-200`, `base-300` | Alternate surfaces and visual separation. | `base-content`      |
| `primary`              | Primary brand or action emphasis.         | `primary-content`   |
| `secondary`            | Secondary brand emphasis.                 | `secondary-content` |
| `accent`               | Additional emphasis.                      | `accent-content`    |
| `neutral`              | Neutral emphasis or UI regions.           | `neutral-content`   |
| `info`                 | Informational feedback.                   | `info-content`      |
| `success`              | Successful outcomes.                      | `success-content`   |
| `warning`              | Caution or attention.                     | `warning-content`   |
| `error`                | Errors or destructive actions.            | `error-content`     |

Use these tokens with Tailwind utilities, such as `bg-primary`,
`text-primary-content`, `border-base-300`, and `text-base-content/60`.

- Semantic tokens resolve through the active theme. Pair backgrounds with
  suitable content tokens and verify contrast, including opacity changes.
- Prefer semantic tokens for theme-dependent UI colors. Fixed colors can be
  appropriate for charts, branding, or content with a stable color meaning;
  check them against every supported background.
- Semantic tokens normally change with the theme without a `dark:` override. Use
  theme-specific variants only when the design requires different styling, not
  simply to repeat the theme's color mapping.

## Apply themes

Set `data-theme` on the page or on a subtree to select an enabled theme:

```html
<section data-theme="dark">
  <div data-theme="light">Content with a different theme</div>
</section>
```

For a form control that selects a theme, see
[theme controller](components/theme-controller.md). Its value must identify an
available theme. Theme selection and persistence should follow the project's
existing behavior.

## Define a custom theme

Add the theme definition to the existing stylesheet. A standalone custom theme
should define the full color and geometry token set rather than depend on
accidental values inherited from another theme. When using the Tailwind
standalone CLI, replace the package-name theme import below with the path to
`daisyui-theme.mjs`; see [build integration](build-integration.md).

```css
@plugin "daisyui/theme" {
  name: "mytheme";
  default: true;
  prefersdark: false;
  color-scheme: light;

  --color-base-100: oklch(98% 0.02 240);
  --color-base-200: oklch(95% 0.03 240);
  --color-base-300: oklch(92% 0.04 240);
  --color-base-content: oklch(20% 0.05 240);
  --color-primary: oklch(55% 0.3 240);
  --color-primary-content: oklch(98% 0.01 240);
  --color-secondary: oklch(70% 0.25 200);
  --color-secondary-content: oklch(98% 0.01 200);
  --color-accent: oklch(65% 0.25 160);
  --color-accent-content: oklch(98% 0.01 160);
  --color-neutral: oklch(50% 0.05 240);
  --color-neutral-content: oklch(98% 0.01 240);
  --color-info: oklch(70% 0.2 220);
  --color-info-content: oklch(98% 0.01 220);
  --color-success: oklch(65% 0.25 140);
  --color-success-content: oklch(98% 0.01 140);
  --color-warning: oklch(80% 0.25 80);
  --color-warning-content: oklch(20% 0.05 80);
  --color-error: oklch(65% 0.3 30);
  --color-error-content: oklch(98% 0.01 30);

  --radius-selector: 1rem;
  --radius-field: 0.25rem;
  --radius-box: 0.5rem;
  --size-selector: 0.25rem;
  --size-field: 0.25rem;
  --border: 1px;
  --depth: 1;
  --noise: 0;
}
```

The palette illustrates the variable structure; choose and verify colors for the
actual interface. Valid CSS color formats include OKLCH and hex.

- `default` and `prefersdark` select the custom theme's default roles.
- `color-scheme` tells the browser which appearance to use for its own UI.
- `--radius-*` controls component corner radii; `--size-*` controls sizing.
- `--border` sets border width. `--depth` and `--noise` use `0` or `1` to
  disable or enable their respective effects.

## Customize a built-in theme

Use the built-in theme name and override only the required variables; other
values are inherited from that theme:

```css
@plugin "daisyui/theme" {
  name: "light";
  default: true;
  --color-primary: oklch(55% 0.2 250);
}
```

Recheck the paired content color whenever its background changes.

## Theme-specific Tailwind variants

If the project needs `dark:` utilities to follow an explicit daisyUI theme,
align the variant selector with that theme. For example:

```css
@custom-variant dark (&:where([data-theme=night], [data-theme=night] *));
```

This selector matches an explicit `data-theme="night"` scope. It does not
automatically mirror every dark theme or system preference; account for the
project's actual theme-selection mechanism.

[Color reference](https://daisyui.com/docs/colors/) and
[theme reference](https://daisyui.com/docs/themes/).
