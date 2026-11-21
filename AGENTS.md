# Maintenance Guidelines

## Scope

This file applies to the entire repository. Keep maintenance guidelines in only
this file and `site/AGENTS.md`; package and tool instructions belong here.
Package maintenance tools belong outside `site/`. All website work requires
reading [site/AGENTS.md](site/AGENTS.md), including Nix registration and
development-tool configuration outside `site/`. Website architecture, data, and
publication conventions belong there; language skills cover implementation
conventions only.

## Documentation

The project's default documentation is the root [README](README). Project
documentation uses Chinese. Skills and their usage instructions use English and
remain in Markdown. `AGENTS.md` files at every level remain in Markdown and may
be entirely in English; they are exempt from the Chinese-language requirement
for project documentation.

Use `README` for the default documentation in project and code directories. Its
first line must be `# -*- mode: org; -*-`, and it must use Org headings, links,
and source blocks. Keep community files in `.github/`, using GitHub-supported
Markdown or YAML formats.

Org documents have a maximum of 80 display columns per complete source line,
including markup and link URLs. Count Chinese characters and full-width
punctuation as two columns and ASCII characters as one. Leave one space between
Chinese and English text in prose. Do not split words, code, or URLs when
wrapping lines; the descriptive text of a long link may wrap. Verify display
width with a facility such as Emacs's `string-width`, not character counts.

The website presents font listings, previews, and license information; do not
append per-package images to README files. Maintain contribution procedures in
[.github/CONTRIBUTING.md](.github/CONTRIBUTING.md) and website operations in
[site/README](site/README). Do not recreate `docs/` or separate copies of
development documentation. Keep website links current. Do not change deployment
workflows without an explicit request.

## CI Maintenance

Validate maintenance tools and CI through actual use. Do not add or maintain
separate test suites for them. Keep source-format and Nix evaluation checks,
runtime validation, and the website's own functional tests.

Keep PR and mainline font builds and their audited binary-cache publication
independent of website publication. Successful PR build receipts are JSON data
on `font-build-state`; the trusted default-branch consumer validates producer
artifacts and never executes PR code. Land compatible consumers before changing
producer formats. Preserve legacy preview receipts during the transition.

Preserve the historical preview branches and the pre-migration `v0.2.0` tag. Do
not restore automatic PNG generation or the preview App. Keep legacy build
receipts readable, and preserve Hercules cache receipts and pending cache
publications when changing CI state.

Website builds use the private Hercules Effect mount and the existing Make
targets. GitHub Pages receives validated release archives; it does not build
fonts. Keep the Pages environment restricted to main and the `ci/site/**` tag
namespace restricted to administrators and Hercules CI. Publication details live
in `site/AGENTS.md`.

## Nix

Before writing, editing, reviewing, or refactoring `.nix` files, use
[nix-coding](.agents/skills/nix-coding/SKILL.md), read its referenced style
guide, and perform the required formatting and verification.

## C and Scheme

Select skills according to the code's execution target:

| Work                                                    | Skill                                                                                                   |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Handwritten C and native font tools                     | [c-coding](.agents/skills/c-coding/SKILL.md)                                                            |
| Native Guile modules, scripts, and tests                | [guile-coding](.agents/skills/guile-coding/SKILL.md)                                                    |
| Native HTTP handling and SXML/HTML                      | [guile-web-coding](.agents/skills/guile-web-coding/SKILL.md), together with the native Guile guidelines |
| Scheme compiled to browser Wasm and its host interfaces | [hoot-coding](.agents/skills/hoot-coding/SKILL.md)                                                      |

Modules that run in both native Guile and Hoot must follow both sets of
guidelines. Guile dependencies available to the compiler are not necessarily
available in Wasm.

## Font Package Metadata

Maintain package information only in `package.nix` under
`passthru.chinese-fonts-overlay-site`. Read the
[actual schema](lib/font-info.nix) and
[contribution guide](.github/CONTRIBUTING.md); do not create a separate
per-package index. Font vendors, styles, and license costs are verified
manually. Languages come from font coverage scans and must be sorted and unique.
Preserve per-package notices, and exclude aggregate packages using the
`isFontAggregate` flag supplied by the composition functions.

License costs follow the project's `gpu` / `gcu` / `paid` convention. Use the
full names `gratisPersonalUse` and `gratisCommercialUse` as field values for
`gpu` (gratis personal use) and `gcu` (gratis commercial use), respectively: a
license can be obtained at no charge for personal or commercial use. `paid`
means a license must be purchased. `free` means no license fee. The `free` cost
value and the license's `free` attribute describe separate dimensions; do not
infer a cost category from the software-freedom classification.

A cost category does not imply the same fee for every use case. For example,
free personal screen display with separately paid printing remains
`gratisPersonalUse`; do not classify a font as `paid` solely because some uses
require payment. Likewise, `gratisCommercialUse` does not promise free licensing
for every commercial use. Verify the permitted purposes, conditions, and
separately charged uses against upstream terms, and record relevant restrictions
and sources in `notices`. A free font download does not establish a free use
license. Do not infer license costs from font scans.

Styles are overlapping labels, not mutually exclusive categories. Preserve all
verified styles in a package, including styles reached through variable axes.
For example, Gothic faces normally use both `hei` and `sans`, while Song faces
use `serif` and `song`. Use `rounded` for rounded typefaces, `handwritten` for
handwriting, and `symbol` for icon, emoji, or dedicated symbol fonts.
Calligraphic or decorative handwriting may also use `cal` or `art`; do not use
either as a catch-all for handwriting. Prefer publisher descriptions, then
inspect actual preview glyphs across relevant faces. Do not infer the whole
package's style from its name or first face. Ask the maintainer when neither
source resolves a classification; `unknown` must stand alone when evidence is
insufficient.

The required `displayName` is the publisher's family or product name, verified
against its homepage or release documentation. Prefer the publisher's local name
when available. Do not concatenate weight names or duplicate translated aliases.
Preserve distinctions between separately packaged regions, families, and
variable-font variants; a package containing multiple independent families must
identify them. Maintain this name in the package rather than deriving it from
font file names or the first face's full name.

The optional boolean `embedding` takes precedence over `meta.redistributable`;
when omitted, derive it from the latter, defaulting to false if that is also
absent. Audit embedding font files in software, websites, or devices against the
package's license and the publisher's original terms. Free commercial use,
rendered output, or document-only embedding does not establish this permission.
Do not mark permission as granted when it requires a separate purchase or
application, or when the available terms do not establish it. A true value still
requires compliance with applicable attribution, license, source availability,
and font replacement conditions. Omit the field when the default is correct;
record overrides and special conditions in package notices with source links.
The public catalog contains the final boolean; the frontend must not infer it
again. Open-source and proprietary categories use the license's explicit `free`
value; missing information remains unknown.

Use `tools/update-font-languages/` to scan and maintain language coverage.
Preserve Fontconfig's languages and supplement Korean per face when all modern
compatibility jamo U+3131–U+3163 and all 11,172 modern Hangul syllables
U+AC00–U+D7A3 are present. Archaic jamo are not required for this supplement. Do
not infer language support from family names or a few sample glyphs. Package
coverage is the union of its faces; rescan when the font or rule changes.

Scan every selected input successfully before preparing source replacements.
Only explicit `--write` updates the language lists, preserving all other fields;
`--check` reports stale records through a nonzero status. Reports containing
local font paths are private maintenance output, not website assets.

## Font Language Tool

Accept complete overlay attributes such as `buttaiwanPackages.genkimin2-jp`, or
paths to `package.nix` within the selected repository. Do not confuse `pname`
with an attribute or accept the website's vendor.package identifiers. Resolve
all selectors before scanning, deduplicate them, and reject unrelated paths.

Preserve the language coverage rules above. Scan every selected package before
preparing replacements. Only `--write` changes language lists; preserve all
other source content. Check mode returns failure for stale metadata.

Keep process arguments separate from source expressions, pass Nix inputs as data
and preserve URL encoding for repository paths. Reports on stdout are JSON;
diagnostics go to stderr. Loading modules must not scan or modify anything.

User-facing maintenance instructions belong in `.github/CONTRIBUTING.md`.

## Development Configuration

Maintain configuration in `tools/dev-shells/default.nix`. `nix develop` creates
Git-ignored links for `.bake.toml`, `.clang-format`, `.editorconfig`,
`prek.toml`, and `treefmt.toml`. Edit the corresponding Nix definitions; do not
edit or commit the generated files.

C uses GNU style. The development environment provides clang-format with the GNU
preset; use it as needed and inspect the diff. Without an explicit request, do
not add it to treefmt, commit checks, or CI, and do not format unrelated source
files.

Handwritten `Makefile`, `GNUmakefile`, `makefile`, `*.mk`, and `Makefile.am`
files have a maximum of 80 columns and must use actual tabs as recipe prefixes.
The development environment provides mbake from the bake project. From the
repository root, run `mbake format --config .bake.toml FILE`; add `--check` to
check without changing files.

The pinned mbake version neither wraps nor rejects overlong lines. Check line
width with `editorconfig-checker -disable-indentation FILE`. Leave indentation
checks to mbake so valid space-indented continuation lines are not mistaken for
missing tabs. When wrapping lines manually, preserve Make and shell quoting and
whitespace semantics. Do not format generated `Makefile.in` files or configured
Makefiles.

## Commits

When creating a commit, use [commit](.agents/skills/commit/SKILL.md), complete
the required staged-change checks, and use a GNU-style commit message. See the
[contribution guidelines](.github/CONTRIBUTING.md) for how to split changes into
commits.
