# README for Agents

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

## Commits

When creating a commit, use the `commit` skill. Load
`.agents/skills/commit/SKILL.md`, follow its required staged-diff inspection
workflow, and write the commit message in the required GNU-style format.
