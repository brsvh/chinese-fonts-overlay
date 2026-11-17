# README for Agents

## Directory instructions

These instructions apply throughout the repository. Read more specific
`AGENTS.md` files for the directories involved in a task.

For website work, read [site/AGENTS.md](site/AGENTS.md), including when changing
its Nix registration or development tooling outside `site/`. Keep website
architecture, data, and publication rules there rather than duplicating them in
language skills. Skills provide implementation conventions and workflows.

## Documentation

When a task mentions the project README, treat it as `docs/README.md`.

## Nix Code

When writing, editing, reviewing, or refactoring `.nix` files, use the
`nix-coding` skill first. Load `.agents/skills/nix-coding/SKILL.md` and its
referenced style guide, then follow that workflow for style, formatting, and
validation.

## C and Scheme code

Select the relevant skill by execution target:

| Work                                              | Skill                                                                                             |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Handwritten C and native font tools               | [c-coding](.agents/skills/c-coding/SKILL.md)                                                      |
| Native Guile modules, scripts, and test drivers   | [guile-coding](.agents/skills/guile-coding/SKILL.md)                                              |
| Native HTTP handling and SXML/HTML generation     | [guile-web-coding](.agents/skills/guile-web-coding/SKILL.md), together with native Guile guidance |
| Scheme compiled to browser Wasm and host bindings | [hoot-coding](.agents/skills/hoot-coding/SKILL.md)                                                |

Use both native Guile and Hoot guidance for modules that run on both targets. Do
not assume that a compiler-side Guile dependency is available in Wasm.

## Development configuration

The devshell configuration is maintained in `tools/dev-shells/default.nix`.
`nix develop` generates `.bake.toml`, `.clang-format`, `.editorconfig`,
`prek.toml`, and `treefmt.toml` as ignored symlinks. Change their Nix
definitions rather than editing or committing the generated files.

C follows GNU style. The devshell supplies clang-format with the GNU preset;
running it is optional. Do not turn it into a required treefmt, commit, or CI
check without an explicit request. Format only relevant authored sources and
review the result.

Handwritten Makefiles (`Makefile`, `GNUmakefile`, `makefile`, `*.mk`, and
`Makefile.am`) use at most 80 columns and literal Tab prefixes for recipes. The
devshell provides mbake from the bake project with `max_line_length = 80`. From
the repository root, run `mbake format --config .bake.toml FILE` as needed; add
`--check` to inspect formatting without editing. Use
`editorconfig-checker -disable-indentation FILE` to check the line limit: the
locked mbake version does not wrap or reject long lines. Let mbake check
Makefile indentation so valid space-indented variable continuations are not
rejected by a generic Tab rule. Split long lines at valid Make/shell
continuation boundaries and review quoting and whitespace semantics. Keep
generated `Makefile.in` and configured Makefiles out of formatter runs.

## Commits

When creating a commit, use the `commit` skill. Load
`.agents/skills/commit/SKILL.md`, follow its required staged-diff inspection
workflow, and write the commit message in the required GNU-style format.
