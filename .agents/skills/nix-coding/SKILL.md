---
name: nix-coding
description: >-
  Rewrite, refactor, or review Nix code to follow this repository's custom Nix
  coding style. Use when asked to restyle, normalize, modernize, reorganize,
  or otherwise edit .nix files according to the bundled Nix style guide.
---

# Nix Coding

Use this skill to change Nix code shape and formatting while preserving
behavior.

## Required workflow

1. Identify the target `.nix` files from the user request, staged diff, or local
   repository context.
2. Read `references/nix-coding-style.md`, relative to this skill directory.
3. Inspect nearby Nix code before editing so local conventions can override
   generic guidance where the style reference allows it.
4. Rewrite only the requested or clearly relevant Nix code. Preserve behavior,
   public interfaces, option names, package choices, and module wiring unless
   the user explicitly asks for semantic changes.
5. Prefer structured Nix edits over text-only reshuffling. Keep generated,
   vendored, lock, or machine-produced files unchanged unless the user names
   them.
6. Format changed `.nix` files with the repository formatter. If the repository
   has no formatter command, use `nixfmt --width 50` when available.
7. Run the narrowest practical validation for the touched code, such as
   formatter checks, Nix evaluation, or existing repository checks.
8. Report the changed files, validations run, and any validation that could not
   be run.

## Refactor priorities

- Apply the bundled style guide before making broader cleanups.
- Preserve local order when order affects semantics, precedence, activation
  behavior, fallback behavior, or user-visible priority.
- Keep comments only when they explain non-obvious intent, workarounds, or
  behavior.
- Prefer small, reviewable rewrites over architecture changes.
- Do not introduce new helper abstractions solely to satisfy formatting.

## Reference

The full style contract is in `references/nix-coding-style.md`. Load it before
changing Nix code, and use it as the source of truth for formatting, expression
shape, naming, comments, flakes, packages, and module idioms.
