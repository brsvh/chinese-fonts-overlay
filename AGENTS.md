# Maintenance Guidelines

## Scope

This file applies to the entire repository. When working in a directory, also
read any more specific `AGENTS.md` that applies there. All website work requires
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
development documentation. The preview website URL is currently only planned; do
not describe it as deployed. Do not change deployment workflows without an
explicit request.

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
