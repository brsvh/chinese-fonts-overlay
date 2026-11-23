# Texinfo patterns

The user manual supplies most patterns below. Formal command, function, face,
and type definitions are supplemental Texinfo mechanisms, useful when writing a
programming reference. They are not claimed to be the dominant layout of the
Emacs user manual. Consult `source-map.md` for provenance.

## Contents

- Semantic inline markup and punctuation
- Nodes, headings, menus, and cross-references
- Tables and displays
- Formal definitions and indexing
- Front matter, included files, and output formats

## Semantic inline markup

| Meaning                   | Example source                                         | Distinction                                                    |
| ------------------------- | ------------------------------------------------------ | -------------------------------------------------------------- |
| Lisp symbol or expression | `@code{demo-notes-refresh}`                            | The identifier, not a keystroke.                               |
| Replaceable argument      | `@var{directory}`                                      | A role the reader supplies, not a Lisp variable's actual name. |
| Key sequence or input     | `@kbd{C-x b}`                                          | Something to type.                                             |
| Named key                 | `@kbd{C-x @key{RET} f}`                                | Use `@key{}` for RET, TAB, SPC, ESC, and similar key names.    |
| Literal text or UI label  | `@samp{No matching notes}`                             | Output, prompts, labels, or literal fragments.                 |
| File or directory         | `@file{notes/}`                                        | A filesystem object or path pattern.                           |
| Shell program             | `@command{emacsclient}`                                | A command-line executable.                                     |
| Command-line option       | `@option{--batch}`                                     | Not an Emacs user option.                                      |
| Environment variable      | `@env{INFOPATH}`                                       | Distinct from Lisp variables.                                  |
| Newly defined term        | `@dfn{note list}`                                      | Use at the definition, not every occurrence.                   |
| Work or manual title      | `@cite{GNU Emacs Manual}`                              | A title, not a node or filename.                               |
| External link             | `@url{https://www.gnu.org/software/emacs/, GNU Emacs}` | Use the target manual's supported URL command.                 |
| Acronym                   | `@acronym{ASCII}`                                      | Do not use capitals merely for emphasis.                       |

Named keys may occur alone as `@key{TAB}` when discussing the key itself. Within
a sequence use `@kbd{@key{TAB}}` or `@kbd{M-@key{TAB}}`. Keep modifiers outside
`@key{}`. The source corpus includes exceptions; choose consistent, semantic
markup for new passages rather than reproducing those exceptions.

Inside `@table @kbd`, the item already has keyboard markup:

```texinfo
@table @kbd
@item @key{RET}
Visit the note on the current line (@code{demo-notes-visit}).
@end table
```

Use `@var{}` inside a code pattern when only part is replaceable:
`@code{(@var{title} . @var{file})}`. Use `@code{nil}` and `non-@code{nil}` for
Lisp values. Do not use `@var{}` merely because the object named in prose
happens to be a variable.

For buffer names, the Emacs corpus uses both `@samp{}` and `@file{}`. Prefer the
target manual's established convention; a buffer is not necessarily a file. In a
new manual, `@samp{*Demo Notes*}` communicates a literal buffer name without
implying a filesystem object.

## Escaping and punctuation

Texinfo punctuation affects the rendered result:

| Intended text                | Source                                             |
| ---------------------------- | -------------------------------------------------- |
| Literal at sign              | `@@`                                               |
| Literal braces               | `@{` and `@}`                                      |
| Email-like literal sample    | `@samp{reader@@example.invalid}`                   |
| Double quotation marks       | Two opening backticks and two closing apostrophes. |
| En dash / em dash in prose   | `--` / `---`                                       |
| Ellipsis                     | `@dots{}`                                          |
| Non-sentence period          | `vs.@:`                                            |
| Sentence end after a capital | `ASCII@.`                                          |

Use `@samp{}` or `@code{}` instead of manually quoting a literal or symbol. Do
not replace straight quotes inside runnable code with typographic quotes.
Texinfo still interprets `@` and braces inside `@example` and `@lisp`; escape
literal instances there too. `@verbatim` is available for genuinely literal
blocks, but prevents semantic markup inside the block.

Use `@w{}` sparingly to keep a short unit together. Wrapping a long command in
it can make output overflow. Use `@*` only when a displayed layout needs an
actual line break, not to force the wrapping of ordinary paragraphs.

## Nodes and headings

A node is a navigation target; a sectioning command supplies a heading and
hierarchy. Their names need not be identical:

```texinfo
@node Visiting Notes
@section Visiting Notes from the List
```

For an ordinary new manual, use `@node Top` with `@top`, then pair chapter,
section, and subsection nodes with the corresponding sectioning commands. Use
`@appendix`, `@appendixsec`, and related commands for appendices, and
`@unnumbered` for unnumbered material such as indexes. Do not skip levels merely
to get a desired visual heading size.

Simple `@node Name` lines let Texinfo derive navigation. Preserve explicit
Next/Previous/Up fields in existing manuals if their special navigation needs
them; do not add those fields mechanically. Node names should be concise,
unique, and stable. A more descriptive printed heading need not force a node
rename.

Use `@anchor{}` for a useful target within a node, such as one glossary entry.
Do not add a separate node just to make every small term linkable.

## Menus

A menu lists the child nodes in the intended reading order. Put explanatory
introductory prose before the menu. Two common forms are:

```texinfo
@menu
* Overview::           What a note list contains.
* Filtering: Filtering the Note List. Select notes by title.
@end menu
```

`* Name::` uses the node name as its label. `* Label: Node Name.` uses a short
visible label and an explicit target. The latter is useful when node names are
long or their repeated prefixes add no information to a menu.

Keep descriptions concise and parallel: an action or a useful explanation, not a
repetition of the label. Align descriptions in ordinary short entries around
column 24 when practical. There is no corpus-wide 20-character label limit;
treat short labels as an editorial aid, or follow a project's explicit limit
when one exists.

Info can hide explicit targets, so source alignment is insufficient. Check menus
with normal reference hiding enabled. Keep a description on one line if it reads
well in the resulting menu; a long hidden target alone is not a reason to wrap
it. Do not shorten an established node name solely to align its menu entry.

Large manuals may use grouped Top menus and `@detailmenu` for deeper navigation.
Introduce those only when the hierarchy benefits; a small manual needs no
replica of Emacs's extensive master menu.

## Cross-references

Choose the form according to the surrounding sentence:

```texinfo
@xref{Filtering Notes}.
For more about filtering, see @ref{Filtering Notes}.
You can also filter the list (@pxref{Filtering Notes}).
```

`@xref` supplies “See”; do not write “See @xref”. `@pxref` supplies
parenthetical-style “see”; include the surrounding parentheses yourself. `@ref`
supplies no introductory word. Use appropriate punctuation after references;
`@xref{Node}, for details.` is also a common Emacs pattern.

Cross-manual form:

```texinfo
@xref{Hooks,,, emacs, The GNU Emacs Manual}.
```

The five positions are node, Info reference name, printed title, Info file, and
manual title. Empty positions still need their separating commas. Use the Info
basename, not the source filename, in the fourth position. Verify that the
external node exists in the supported target manual; compilation alone cannot
establish that. HTML may additionally need the project's external-reference
mapping, such as `htmlxref.cnf`.

Use node references for other manual topics and URL markup for web pages. Do not
make an internal link depend on a generated HTML filename or page number. Add
enough context that the reader knows why following a link helps.

## Tables, lists, and displays

- `@table @kbd`: related keys and their effects.
- `@table @code`: literal values or identifiers with descriptions.
- `@table @samp`: literal UI labels or textual choices.
- `@table @asis`: descriptive terms whose entries carry their own markup.
- `@itemize @bullet`: unordered peer items.
- `@enumerate`: steps whose order matters.
- `@ftable @code` / `@vtable @code`: tables that also index function or variable
  item names automatically.

Use `@itemx` for another label sharing an item's description; write a new
`@item` when the description differs. Blank lines between items keep source
readable. Avoid dense multicolumn tables when a description list explains the
choices more clearly in Info.

Use `@example` for commands, code, or fixed-width output. `@lisp` explicitly
identifies Lisp examples; both occur in the Emacs sources. `@smallexample` is
useful for a genuinely wide display, not a general cure for oversized examples.
`@display` is an unfilled text display without the same code role.

```texinfo
  In a title, point can occur between any two characters:

@example
Meeting @point{}notes
@end example

@noindent
Here point is immediately before the first character of @samp{notes}.
```

A new thought after an example begins a normal paragraph instead of using
`@noindent`. Use `@group` only to keep a short display together in printed
output. Long groups impede pagination. Explanatory annotations in code can use
`@r{}`; they must not masquerade as literal program output.

## Formal definitions

Use the form that describes the interface's role:

| Interface                                   | Form                                      | Automatic index |
| ------------------------------------------- | ----------------------------------------- | --------------- |
| Interactive command                         | `@deffn Command demo-notes-refresh`       | Function (`fn`) |
| Lisp function                               | `@defun demo-notes-entries directory`     | Function (`fn`) |
| User option                                 | `@defopt demo-notes-directory`            | Variable (`vr`) |
| Other variable, including a non-option hook | `@defvar demo-notes-refresh-hook`         | Variable (`vr`) |
| Face                                        | `@defvr Face demo-notes-title`            | Variable (`vr`) |
| Documented data type                        | `@deftp {Data Type} demo-note title file` | Type (`tp`)     |

Select `@defopt` for a hook that is itself a user option. Face categories are a
semantic use of the generic `@defvr` form, not a special Texinfo face command.
`@defun` already formats its arguments as variables; do not wrap its plain
argument names in redundant `@var{}` commands. Within the body, refer to them
using `@var{}`.

Close a definition using the original command name, for example `@end deffn`,
not `@end Command`. Multiple signatures sharing one description can use the
matching `x` form, such as `@deffnx` or `@defunx`.

Continue a long signature with a lone `@` at the end of each continued line:

```texinfo
@defun demo-notes-map-entries function directory @
  &optional include-hidden
Call @var{function} once for each entry in @var{directory}.
@end defun
```

This is a syntax illustration, not a complete function contract. A real
reference must also specify argument types, ordering, callback arguments, return
value, errors, and effects as applicable. Ordinary newlines without `@` end the
signature; `@*` is not signature continuation syntax.

The Emacs user manual often gives command and variable reference in prose with
adjacent index entries, and occasionally uses `@defopt` and `@defvar`. Do not
replace a readable user task with a forest of definitions merely because formal
definitions are available. Use formal entries where the manual or task needs a
precise interface reference.

## Indexes

Place indexes at the authoritative explanation, not every occurrence:

```texinfo
@cindex filtering notes
@cindex notes, filtering
@kindex / @r{(Demo Notes list)}
@findex demo-notes-filter
```

Use `@vindex` for variables and hooks described in prose. Index a face with
`@vindex` unless its definition already does so; add a useful concept entry for
its visual role. A definition, `@ftable`, or `@vtable` may already index the
symbol, so do not produce duplicate entries at the same location.

Keep distinct concepts discoverable through familiar terms, but avoid
combinatorial synonym lists. Mode-specific key index entries should identify the
mode, since a single key has many meanings. Define custom indexes only when they
provide a real navigation benefit; `emacs.texi` uses one for shell options,
which are different from Lisp user options.

Include corresponding `@printindex cp`, `fn`, `vr`, `ky`, and `tp` commands in
suitable index nodes for the indexes actually used. For a small manual, related
indexes can share one node under descriptive `@heading` lines. Indexes can also
be merged deliberately using `@synindex` or `@syncodeindex`; check resulting
typeface and navigation rather than merging by habit.

## Front matter and output portability

For an independent manual, provide a coherent identity and navigation:

- `\input texinfo`, an Info filename, a title, and the document language.
- Encoding when needed; Emacs's `docstyle.texi` specifies UTF-8.
- The manual's actual version, maintained in one place when reused.
- Its existing copying notice, an appropriate title page, and Top node.
- An Info directory entry if the manual is intended for installation.
- Menus, content nodes, indexes, and `@bye`.

Use `@copying` and `@insertcopying` to reuse the authentic notice. Preserve its
wording and attribution. If it already includes the manual's title and version,
the Top introduction should explain purpose rather than repeat that statement. A
title page and Top belong to different output contexts; inspect both outputs
before deciding that a repetition is necessary.

Use `@include` to maintain substantial parts separately when useful, not to
create tiny files for every definition. Included fragments need no separate Top
or `@bye`. Use `.texi` for newly created sources unless the project has an
explicit other convention. Do not copy Emacs's relative output paths,
version-generation machinery, or conditional print hierarchy into a small
independent manual without a reason.

Keep shared content in semantic Texinfo. Use `@ifinfo`, `@ifhtml`, or `@iftex`
only for a real output-specific need. Emacs's hosted-site HTML block, book
typography, and old quote-compatibility variables solve its particular
publishing requirements. They are not generic defaults.

Prefer external CSS via `--css-ref` when styling HTML is requested; preserve the
project's selected stylesheet and standard Texinfo HTML semantics. Do not create
a custom theme as a side effect of a writing task. Retain standard license text
in its provided Texinfo form instead of retypesetting it or borrowing Emacs's
unrelated invariant sections and cover text requirements.
