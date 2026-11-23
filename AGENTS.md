# Maintenance Guidelines

These conventions apply to everyone maintaining this repository, including
agents. Read the root [README](README) for usage and
[CONTRIBUTING.md](.github/CONTRIBUTING.md) for the contribution workflow.

## Scope and documentation

Keep maintenance instructions in this file and [site/AGENTS.md](site/AGENTS.md)
only. Read the latter for any website work, including its Nix registration and
development environment. Package definitions and maintenance tools belong
outside `site/`; website architecture and publication conventions belong there.

Project documentation uses Chinese. Default documentation files are named
`README`, start with `# -*- mode: org; -*-`, and use Org headings, links and
source blocks. Use one level-one heading and no `#+title`. Keep community files
in `.github/` in GitHub-supported formats. Skills, their usage instructions and
these two `AGENTS.md` files may use English Markdown.

Write for readers using or maintaining the project. Describe current interfaces
and stable conventions, not session history, intermediate attempts or deployment
status. Keep contribution instructions in `.github/CONTRIBUTING.md` and website
operations in `site/README`. The user manual lives in `docs/` as Texinfo;
`docs/README` explains its local build. Do not add per-package README previews
or duplicate development guides.

Org source lines are limited to 80 display columns, including markup and URLs.
Chinese characters and full-width punctuation count as two columns. Verify with
Emacs `string-width` or an equivalent display-width facility. Leave a space
between Chinese and English text or inline markup, including after Chinese
punctuation. Do not split words, code or URLs; a long link's description may
wrap.

## User manual

Use [texinfo-writing](.agents/skills/texinfo-writing/SKILL.md) for the manual.
Write original Chinese explanations in the style of the GNU Emacs user manual;
the manual is CC0, not a copy of Emacs documentation. Referenced fonts and
upstream material retain their own licenses. Use Texinfo nodes, menus, semantic
markup and indexes; keep node identifiers stable when changing display titles.

Keep authored guidance under `docs/`. Put all vendors under one font-reference
chapter, with vendor sections and package subsections. Generate the complete
reference by evaluating the pinned Nix sources. This project provides an overlay
and packages, not a module-option interface. Do not invent options or maintain a
parallel metadata list. Share catalog extraction through `lib/font-catalog.nix`;
composition functions expose their actual `fontMembers`. Distinguish directly
extracted source collections from composed collections.

Metadata evaluation must not realize fonts or rewrite package files. Escape all
metadata inserted into Texinfo, preserve notices and every upstream link, and
exclude private paths. Manual coverage is independent of website `PACKAGES`
selection. Keep generated files under ignored build directories. Build HTML and
Info and check coverage and links with `make -C docs check` in the docs shell.
Inspect integrated pages in a browser after changing the layout.

## Font packages

Maintain catalog information only in `package.nix`, under
`passthru.chinese-fonts-overlay-site`. The schema is
[lib/font-info.nix](lib/font-info.nix); field meanings and review criteria are
in the contribution guide. Reuse this validator for the catalog and
whole-collection flake check. Exclude packages marked `isFontAggregate`; do not
maintain a separate package index.

Verify publisher names, homepages, styles, fees and permissions against upstream
sources. Preserve distinctions between separately packaged families, regions and
variable variants. Styles overlap and must cover relevant faces and axes; do not
classify an entire package from its name or first face. Inspect previews when
upstream descriptions are insufficient, then ask a maintainer if still unclear.
`unknown` must stand alone. Preserve notices and their source links.

Keep license cost, software freedom, redistribution and embedding distinct. Free
downloads or commercial use do not establish redistribution or embedding rights.
A fee category need not cover every use case; record relevant limits and
separately charged uses. Omit `embedding` when its default is correct; otherwise
record the override and source in notices. The default is
`meta.redistributable`, or false when absent. Publish the resolved boolean; the
frontend must not infer it again. Missing license freedom remains unknown.

Languages are sorted, unique coverage results from
`tools/update-font-languages/`. Preserve Fontconfig results and supplement
Korean per face only when all modern compatibility jamo U+3131–U+3163 and all
11,172 modern Hangul syllables U+AC00–U+D7A3 are present. Archaic jamo are not
required. Package coverage is the union of its faces. Empty coverage is valid;
do not infer languages from names or sample text. Rescan after font or detection
changes.

The tool accepts complete overlay attributes or repository `package.nix` paths,
not `pname` or website identifiers. Resolve and deduplicate all selectors before
scanning; reject unrelated paths. Scan all inputs before preparing replacements.
Only `--write` changes language lists, preserving other source content;
`--check` fails for stale records. Pass Nix inputs as data, preserve URL
encoding and keep arguments separate from source expressions. JSON reports go to
stdout and diagnostics to stderr. Reports containing local paths stay private.
Module loading must have no scanning or writing effects.

## CI

Validate tools and CI through actual use; do not add separate test suites for
them. Retain formatting, Nix evaluation, runtime validation and website tests.
Every PR checks all non-aggregate package metadata without realizing fonts.
Language verification is independent of build receipts: compare font
derivations, recorded languages and the scanner, then scan affected packages.
Report fonts requiring local Windows sources as unverified, not successful
scans.

Keep PR/mainline font builds, audited binary-cache publication and website
publication independent. PR build records are JSON on `font-build-state`. The
trusted default-branch consumer validates producer identity, context and data;
it must never execute PR code. Keep the strict current record schema and
coordinate producer/consumer changes after prior runs finish. Do not upload
restricted font files, source archives, private scans or unaudited closures.

Use camelCase Hercules categories: `planFonts`, `buildFont/<package>`,
`publishFont/<package>` and `buildSite`. Font builds are ordinary Nix outputs;
credentialed publication uses Effects. Publication control is JavaScript in
`ci/`, exposed through `nix run .#ci`; website generation and archive validation
are Guile in `site/`. Transport fields are contracts, not cosmetic job names.

Preserve cache receipts and pending publications. Mainline planning uses its
saved inventory or audits current packages against verified cache receipts. Font
triggers use `ci/package/<package>/<revision>/<uuid>`; delete verified internal
references only at their expected revisions. Preserve historical version tags,
including `v0.2.0`. Do not restore preview branches, preview Apps, PNG tooling
or old-format compatibility. Website transfer uses no tags or Releases. Keep
deployment policy separate from font-cache state, and do not change repository
protection or deployment configuration without a request.

## Implementation and verification

Before editing or reviewing Nix, read
[nix-coding](.agents/skills/nix-coding/SKILL.md) and its style reference; use
the repository formatter and verify the affected evaluation. Font packages use
the root lock, while development tools use `tools/flake.lock`.

Use [c-coding](.agents/skills/c-coding/SKILL.md) for handwritten C,
[guile-coding](.agents/skills/guile-coding/SKILL.md) for native Scheme,
[guile-web-coding](.agents/skills/guile-web-coding/SKILL.md) for HTTP or SXML,
and [hoot-coding](.agents/skills/hoot-coding/SKILL.md) for browser Wasm. Shared
Scheme follows both execution targets' rules; native dependencies are not
necessarily available in Hoot. Skills define implementation conventions, not
repository architecture.

Choose verification by the changed behavior. Build and inspect affected fonts,
check their languages and preview relevant faces. Run website fixture tests for
website changes and inspect UI changes in a browser. Check documentation links,
commands and formatting without rebuilding the collection. State what was and
was not verified.

Maintain development configuration in `tools/dev-shells/default.nix`.
`nix develop` creates ignored links for `.bake.toml`, `.clang-format`,
`.editorconfig`, `prek.toml` and `treefmt.toml`; edit their Nix definitions, not
these generated files. Use GNU clang-format when needed; do not add C formatting
to treefmt, hooks or CI without a request, or format unrelated files.

Handwritten Makefiles use real recipe tabs and at most 80 columns. From the
root, run `mbake format --config .bake.toml FILE` (add `--check` to inspect
only), then `editorconfig-checker -disable-indentation FILE` for line widths.
The pinned mbake does not enforce width; preserve quoting and whitespace when
wrapping. Do not format generated Makefiles.

## Commits

Preserve unrelated local changes. Split commits by independent purpose,
following the contribution guide. Before committing, use
[commit](.agents/skills/commit/SKILL.md), review staged changes and complete its
checks. Use English GNU-style subjects and file bullets. Do not claim checks
that were not run.
