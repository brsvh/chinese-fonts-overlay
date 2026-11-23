# Source map and limits of the extraction

## Corpus

The primary source is the GNU Emacs user manual, available as `(emacs)` in Info
and under `doc/emacs/` in the GNU Emacs source tree. The map below uses
source-relative filenames and Info node names, not machine-specific paths or
line numbers. Names can change between releases; consult the version relevant to
the work when checking a passage.

The bundled guides contain the extracted conventions. Access to an upstream
source tree or installed manual is optional and useful for resolving a question
about a convention; neither is required to use the skill.

The guides summarize writing decisions in new prose. Their examples are newly
written and use an explicitly imaginary package. They do not reproduce whole
Emacs passages or license text. A style specimen does not verify the behavior of
software documented elsewhere.

## Representative passages

Filenames in this table are relative to `doc/emacs/` in a GNU Emacs source tree.
Info nodes can also be found in an installed or published manual.

| Source and node                                                               | What to inspect                                                            | Guidance derived from it                                                             |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `emacs.texi`, front matter and `Top`                                          | Title, version include, copying block, directory entry, Top, grouped menu. | Manual identity, format-aware front matter, navigation.                              |
| `emacs.texi`, `Key Index`, `Command Index`, `Variable Index`, `Concept Index` | Separate index nodes and print commands; custom option index.              | Indexes are part of the reading interface.                                           |
| `docstyle.texi`                                                               | UTF-8, quotation settings, TeX hyphenation.                                | Shared settings exist, but old compatibility workarounds are contextual.             |
| `commands.texi`, `User Input`, `Keys`, `Commands`                             | Definitions of events, keys, commands, and bindings.                       | Introduce terminology, pair input with command names, distinguish key from function. |
| `windows.texi`, `Windows`, `Basic Window`, `Split Window`                     | Concepts, key table, state effects, prefix arguments, settings.            | Explain concepts before task variants; distinguish buffer, window, frame, and point. |
| `mark.texi`, `Mark`, `Setting Mark`                                           | Region and mark definitions, command summary, worked action.               | Define terms at first use and show a concrete result.                                |
| `modes.texi`, `Modes`, `Major Modes`                                          | Major/minor distinction, buffer-local state, configuration examples.       | Scope and activation are part of the explanation.                                    |
| `regs.texi`, `Registers`, `Text Registers`                                    | Purpose, argument notation, multi-value option table, key examples.        | Explain values individually and motivate tasks.                                      |
| `custom.texi`, `Changing a Variable`, `Saving Customizations`                 | UI labels, saving versus setting, code and prose.                          | Separate session state from persistence and describe visible actions.                |
| `custom.texi`, `Directory Variables`                                          | Structured examples followed by their interpretation.                      | Explain example effects without reflowing the code.                                  |
| `dired.texi`, `Dired`, `Dired Enter`                                          | Mode context, read-only buffer, explicit menu targets, invocation.         | Task-based nodes and short labels with stable targets.                               |
| `dired.texi`, `Dired` source comment                                          | Warning that the tutorial references this node.                            | Renaming nodes can break callers outside the manual.                                 |
| `dired.texi`, `Dired Visiting`, `Shell Command Guessing`                      | `@defopt` and `@defvar` entries.                                           | Formal variable definitions occur, but are not the only user-reference style.        |
| `package.texi`, `Package Menu`                                                | Item list, mode-specific key indexes, `@itemx`, network effects.           | Tables need context, indexing, and meaningful consequences.                          |
| `package.texi`, `Package Installation`                                        | `package-archives` definition with structured values.                      | Describe the shape and interpretation of configuration data.                         |
| `calendar.texi`, `Diary iCalendar Import`                                     | Function table, variable table, hook example.                              | `@ftable` and `@vtable` combine description with indexing.                           |
| `killing.texi`, `Appending Kills`                                             | `@point{}` display and `@noindent` continuation.                           | Use portable textual demonstrations with explained results.                          |
| `trouble.texi`, `Screen Garbled`, `Text Garbled`                              | Symptom, distinguishing check, different recovery actions.                 | Organize diagnosis by observable behavior.                                           |
| `cmdargs.texi`, `Emacs Invocation`, `Action Arguments`                        | Appendix hierarchy, CLI concepts, option index.                            | Separate shell options from Lisp settings; retain argument syntax.                   |
| `glossary.texi`, `Glossary`                                                   | `@table @asis`, anchors, short definitions, references.                    | Link terms without a node for every entry.                                           |
| `doclicense.texi`                                                             | Standard license included as a fragment.                                   | Preserve licensing text and its intended inclusion structure.                        |

The repository root's `.dir-locals.el` explicitly sets `fill-column` to 72 and
`sentence-end-double-space` to `t`. Two-space first-line indentation is visible
throughout ordinary prose; the corpus also contains exceptions.

## Supplemental syntax source

The GNU Texinfo manual documents reference mechanisms that are uncommon or
absent in the Emacs user manual's selected passages. Relevant Info nodes are:

- `(texinfo) Def Cmd Template`
- `(texinfo) Def Cmd Continuation Lines`
- `(texinfo) Functions Commands`
- `(texinfo) Variables Commands`
- `(texinfo) Data Types`

These support the definition forms, a lone `@` for signature continuation, and
automatic indexing. They do not turn API-reference structure into a requirement
for every user-facing chapter. Consult `(texinfo)` in Info or the corresponding
published manual for the Texinfo version being used.

## What was deliberately not generalized

- Menu widths and descriptions vary; no universal 20-character label rule was
  found. The guidance to keep labels short is an editorial choice.
- Not every prose paragraph is indented identically. New prose adopts the common
  layout; a review should not blindly rewrite all historical text.
- The Top node can repeat information from the copying notice. Avoiding
  redundant title/version prose is a cleanup recommendation, not a claim that
  the source always does so.
- Emacs's old processor compatibility settings, TeX-only adjustments,
  conditional chapter hierarchy, and hosted-site HTML are special cases.
- Buffer names have inconsistent inline markup. Prefer semantic clarity and the
  target manual's established convention.
- `@deffn Command`, `@defun`, `@defvr Face`, and `@deftp` are useful
  supplemental reference patterns, not the main organization of this user
  manual.
- A source example's existence does not establish correctness for another
  program or release. Verify actual bindings, defaults, and APIs anew.
- Documentation scope, package boundaries, language, stylesheet, and editor
  configuration are decisions for the target project, not universal rules
  extracted from this corpus.
