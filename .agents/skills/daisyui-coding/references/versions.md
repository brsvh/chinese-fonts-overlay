# Version alignment

The bundled guides use this reference baseline:

| Item                                      | Reference version                          |
| ----------------------------------------- | ------------------------------------------ |
| daisyUI components and standalone plugins | 5.7.39                                     |
| Tailwind CSS standalone compiler          | 4.3.4                                      |
| Official skill snapshot                   | The skill shipped in daisyUI v5.7.39       |
| daisyUI source commit                     | `dd0a94a20ae35c7587017766cef9f0c109ff819b` |

The official skill's own metadata says `5.7.x`; the release and commit above
identify the precise snapshot. Its broad version label alone does not prove that
a component exists in every daisyUI 5 release.

Use these pinned sources when checking the bundled guides:

- [Official skill and subguides](https://github.com/saadeghi/daisyui/tree/dd0a94a20ae35c7587017766cef9f0c109ff819b/skills/daisyui)
- [Component implementation](https://github.com/saadeghi/daisyui/tree/dd0a94a20ae35c7587017766cef9f0c109ff819b/packages/daisyui/src)
- [Release and standalone bundles](https://github.com/saadeghi/daisyui/releases/tag/v5.7.39)
- [Tailwind CSS v4.3.4](https://github.com/tailwindlabs/tailwindcss/releases/tag/v4.3.4)

The official skill is an API reference here. Its generic installation and design
suggestions do not override the consuming project's pinned environment,
renderer, language, or accepted design. Live component documentation may be
newer than the release; resolve disagreements against the release's code.

For example, the v5.7.39 skill describes only the radio `filter` variant, while
that release's CSS also handles checkboxes without hiding unselected options.
The local filter guide reflects that inspected behavior. Do not infer support
solely from a newer documentation example.

When adopting a different version, inspect the target's lockfile or packaged
derivation, check the affected component and plugin APIs, and compile with the
actual compiler/plugin pair. Update the reference versions and affected guides
together when maintaining this skill. Keep `daisyui.mjs` and `daisyui-theme.mjs`
on the same release. Do not silently upgrade a project's dependencies just to
match this baseline.
