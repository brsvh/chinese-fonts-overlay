---
name: texinfo-writing
description: >-
  Write, edit, organize, and review Texinfo manuals in the style of the GNU
  Emacs user manual. Use for .texi documentation, Info node and menu design,
  semantic markup, command and option reference, indexes, and rendered Info
  and HTML checks. Also use when converting prose into a Texinfo manual;
  do not apply its formatting rules to unrelated Markdown or Lisp files.
---

# Texinfo Writing

Produce manuals that readers can learn from in order and consult through nodes,
menus, cross-references, and indexes. The primary style model is the GNU Emacs
user manual, not its source-file organization or every historical formatting
exception. The bundled guides and examples are self-contained; no Emacs source
checkout or particular installation layout is required.

## Workflow

1. Establish the audience, requested scope, existing manual structure,
   implementation version, and required outputs. An outline request calls for an
   outline, not permission to create a manual. Follow the target project's
   instructions, language, license, and established names.
2. Read the affected source and its callers or upstream documentation to verify
   behavior. Check commands, bindings, defaults, scope, side effects, and
   dependencies before explaining them. A style exemplar is not proof that its
   software behavior applies to another version or package.
3. Read [writing-style.md](references/writing-style.md) for a new chapter or
   substantial prose revision. Use its concept-to-task progression and
   distinguish user guidance from programming contracts.
4. Consult [texinfo-patterns.md](references/texinfo-patterns.md) when changing
   markup, nodes, menus, definitions, indexes, or front matter. It separates
   observed Emacs conventions from supplemental Texinfo reference forms.
5. For a complete worked example, read
   [example-manual.texi](references/example-manual.texi). Its imaginary package
   demonstrates structure and markup; it is neither an actual API nor a
   ready-made licensing template. Use only the relevant pattern.
6. For references generated from source data or Nix evaluation, read
   [generated-reference.md](references/generated-reference.md). Separate factual
   extraction from authored explanations and verify coverage.
7. Build and inspect the requested formats using
   [validation.md](references/validation.md). Check navigation and reading
   experience, not only compiler exit status. Report any unperformed checks.

For attribution, representative source passages, and disputed conventions,
consult [source-map.md](references/source-map.md). When an upstream source or
manual is available, use its filenames and Info node names to find the
corresponding kind of passage rather than copying a whole chapter. Resolve
bundled reference paths relative to this skill directory.

## Essential decisions

- Organize around readers' concepts and tasks. Explain purpose and the ordinary
  case before variants, exceptions, and internals. Give a node enough context to
  work when reached directly from an index.
- Assign each behavior one authoritative explanation; use cross-references for
  its prerequisites and related material. Do not reproduce docstrings as an
  outline or create a node for each symbol mechanically.
- When documenting Emacs, distinguish point, buffer, window, frame, modes,
  commands, functions, user options, hooks, and faces. For other software, use
  its own vocabulary; an Emacs writing style does not turn package attributes or
  function arguments into Emacs user options. Introduce unfamiliar terms with
  `@dfn{}` at their defining occurrence.
- When describing a keyboard-driven interface, pair a default key with its
  command, for example `@kbd{C-x b} (@code{switch-to-buffer})`. Distinguish
  supplied bindings from user-defined example bindings. Name the applicable
  buffer or mode.
- Mark meaning, not appearance: `@code`, `@var`, `@kbd`, `@key`, `@file`,
  `@samp`, and `@option` are not interchangeable monospace wrappers.
- For new English prose following this style, indent an ordinary paragraph's
  first line by two spaces, leave continuation lines at the left margin, and
  fill to 72 columns. Keep two spaces between sentences. Do not apply prose
  filling to examples, menus, definition signatures, or literal text. For
  Chinese prose, count display columns, preserve natural punctuation and
  Chinese/Latin spacing, and do not impose English double sentence spaces. Use
  the project's documented width and indentation conventions.
- Keep existing node names stable where possible. Match nodes to section
  hierarchy and menus. Use shorter menu labels with explicit targets when
  useful; judge alignment in rendered Info, where targets may be hidden.
- Index concepts in readers' vocabulary and public symbols at their substantive
  explanations. Account for automatic indexing by definition commands and
  `@ftable`/`@vtable` before adding manual entries.
- Keep examples small, coherent, and explicit about their prerequisites and
  effects. Use `@noindent` only when text after a display continues the
  preceding explanation.
- Preserve the target manual's copyright, attribution, and licensing. Emacs's
  invariant sections, cover texts, publisher details, and old processor
  workarounds are not defaults for unrelated manuals.

## Boundaries

The skill recommends an Emacs-derived style, not universal Texinfo syntax
requirements. An existing manual can legitimately use other paragraph spacing,
menu widths, front matter, or reference layouts. Follow explicit project rules
without turning them into requirements for other projects. In particular, do not
infer a ban on installation or build documentation, require one manual per
package, impose a particular HTML stylesheet, or modify editor configuration
without task context.

The source corpus contains inconsistent and historical passages. Adopt patterns
that clarify meaning and survive multiple output formats; do not replicate an
apparent typo or an unnecessary format-specific workaround.
