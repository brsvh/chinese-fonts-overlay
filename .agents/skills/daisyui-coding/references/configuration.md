# daisyUI Configuration

Read this reference when changing the existing daisyUI plugin configuration. Use
the project's CSS entry point and preserve unrelated options. For dependency
provisioning, standalone plugin paths, or generated templates, read
[build integration](build-integration.md). The package-name imports below assume
a Node package resolution setup; standalone builds use local bundles.

## Plugin options

Options belong inside the CSS `@plugin "daisyui"` block. Omit settings that do
not need an override.

| Option    | Purpose                                                                  |
| --------- | ------------------------------------------------------------------------ |
| `themes`  | Select built-in themes and their default roles.                          |
| `root`    | Choose the selector receiving global CSS variables; defaults to `:root`. |
| `include` | Limit generated library modules to the specified module names.           |
| `exclude` | Exclude specified library modules.                                       |
| `prefix`  | Prefix daisyUI class names.                                              |
| `logs`    | Enable or disable plugin logging; defaults to `true`.                    |

## Theme selection

The default theme selection is `light --default, dark --prefersdark`. To choose
a different set:

```css
@plugin "daisyui" {
  themes: light --default, dark --prefersdark, cupcake;
}
```

- `--default` marks the default theme.
- `--prefersdark` marks the theme selected by the dark system preference.
- `themes: all;` enables all built-in themes.
- `themes: false;` disables built-in themes, for example when defining only
  custom themes.

Keep the selection aligned with themes actually used by the interface. See
[colors and themes](colors-and-themes.md) for applying or customizing them.

## Scope, prefixes, and modules

For example, this configuration scopes global variables, excludes a base module,
prefixes daisyUI classes, and disables plugin logging:

```css
@plugin "daisyui" {
  root: "#app";
  exclude: rootscrollgutter;
  prefix: "daisy-";
  logs: false;
}
```

With this daisyUI prefix, `btn` becomes `daisy-btn`. If the project also uses a
Tailwind prefix, follow the combined prefix conventions of its actual versions;
do not rename classes using a blanket text replacement.

Use library module names for `include` and `exclude`, such as `button`, not the
corresponding CSS class `btn`. Base modules include `properties`, `rootcolor`,
`scrollbar`, `rootscrolllock`, `rootscrollgutter`, and `svg`. Check affected
overlays and page scrolling when changing those modules.

Use utility classes or shared component CSS for visual changes. Module inclusion
controls which library styles are emitted.

[Configuration reference](https://daisyui.com/docs/config/)
