# Writing style and topic design

This guide distills the narrative practice of the GNU Emacs user manual. The
source map identifies passages behind the recommendations. Examples below are
newly written; `demo-notes-*` names describe an imaginary package.

## Contents

- Audience and progression
- Node size and topic ownership
- Explanations of commands, settings, and modes
- Terminology and voice
- Examples and troubleshooting
- Source layout

## Audience and progression

Start with what the feature lets the reader do and the concepts needed to use
it. Move from the ordinary task to related variations, settings, and limits.
`windows.texi` first explains the relationship between windows and buffers; its
splitting section then describes keys, selected windows, point, and numeric
arguments. `regs.texi` first explains the uses and names of registers, then
gives separate tasks for storing different kinds of data.

A useful progression within a topic is:

1. Purpose and context: what problem the feature solves and where it works.
2. Ordinary use: the command or action and its observable result.
3. Relevant control: arguments, options, scope, and persistence.
4. Consequences and limits: changed state, failure, cancellation, or cases that
   materially alter the reader's next action.
5. A cross-reference for a different task or deeper programming detail.

This is a reasoning order, not a mandatory five-paragraph template. A short
topic may need only two paragraphs. Place an essential restriction before the
action it restricts, not at the end of a long section.

Write to the intended audience. An end-user chapter should explain the effect of
an option without requiring knowledge of internal data structures. A programming
topic should state the data structure precisely. The Emacs user manual links to
the Emacs Lisp Reference Manual for internal contracts instead of explaining all
of them inline.

## Node size and topic ownership

Organize a chapter around a reader's work, not around the filenames or
declaration order of the implementation. Headings such as “Opening Notes”,
“Filtering the List”, and “Saving Changes” describe separate tasks. “Variables”,
“Miscellaneous Helpers”, and “demo-notes-core.el” usually do not.

A leaf node should answer one coherent question. Split when readers need
different prerequisites or perform independently useful tasks. Keep closely
related dimensions, limits, and small examples together. For example, horizontal
and vertical spacing can share one spacing topic; an unrelated export workflow
deserves its own node.

Introduce every topic sufficiently for someone entering from an index:

```texinfo
@node Filtering Notes
@section Filtering the Note List

  The note list can show only entries whose titles contain a given
string.  Filtering changes which entries are displayed; it does not
change the note files.
```

Avoid unexplained “this”, “the above command”, and references to a previous
chapter's discussion as the only context. References such as “the following
example” are fine when their object is immediately adjacent.

Give a concept one authoritative explanation. A short command summary can point
to a detailed topic without duplicating every exception. A tutorial may
demonstrate a default while linking to the full option reference. When moving
text, update menus, internal references, and known external users of the node;
Dired's source explicitly notes a node used by the Emacs tutorial.

Plan navigation and content together. Do not create empty nodes for future
features. Preserve a useful existing node name even if the printed heading can
be improved independently.

## Commands: from invocation to effect

The characteristic user-manual pattern pairs a key sequence with its command
name, then explains behavior in ordinary language. Key tables are helpful for a
small related family of actions; they do not replace the explanation.

```texinfo
@kindex g @r{(Demo Notes list)}
@findex demo-notes-refresh
  In the note list, type @kbd{g} (@code{demo-notes-refresh}) to read
the note titles again.  The command keeps point on the same note if
that note still exists.
```

When relevant, explain:

- Which buffer or mode accepts the command and whether it changes the selected
  window, current buffer, point, mark, or region.
- What the minibuffer asks for, how the default is obtained, and the result of
  accepting empty input. Do not invent a prompt or default.
- What a prefix argument changes. Distinguish a raw prefix argument from a
  numeric count when the implementation does.
- Side effects such as changing buffer text, saving files, marking entries,
  creating a subprocess, or persisting settings.
- What happens on error or cancellation, particularly whether earlier work
  remains. For asynchronous commands, separate starting an operation from its
  completion and state how the reader observes completion.

Only include details that actually apply. Do not attach an exhaustive failure
checklist to every small command. In a programming reference, document arguments
and return values explicitly; user instructions seldom need the Lisp return
value of an interactive command.

If there is no default binding, write `@kbd{M-x demo-notes}`. If an example
assigns a key, label it as user-defined and specify where to put the form. Do
not present that example key as a package default.

## Options, variables, hooks, and faces

Explain the behavior an option controls before listing its values. State its
default and the meaning of special values such as `nil`; do not assume that
`nil` always means “off”. The register-preview example in `regs.texi` shows why
a value-by-value explanation can be necessary.

```texinfo
@defopt demo-notes-sort-order
This option specifies the order of entries in the note list.  Its
default value is @code{title}.

@table @code
@item title
Sort by title, ignoring case.

@item newest
Show the most recently modified note first.
@end table

Changing this option affects the next refresh of each note list.
@end defopt
```

Distinguish these concerns when they matter:

- **Scope:** global value, default value, buffer-local value, or value owned by
  a window or frame. “Applies to every buffer” and “is buffer-local” are
  different claims.
- **Activation:** read when loading, entering a mode, creating a buffer,
  refreshing, or on each command invocation.
- **Persistence:** setting for this session, saving through Customize,
  initialization-file configuration, or data written independently.
- **Allowed values:** type, units, ranges, order, precedence, and special
  values. Describe an alist or plist's entries when users must construct it.
- **Ownership:** whether users should customize the value or merely inspect it.
  Do not call every `defvar` a user option.

A hook explanation should give its timing, arguments (if any), relevant current
buffer, and intended use. A face explanation should identify what text it
affects and any inheritance or precedence that changes the result. Index both
hooks and faces. For long extension contracts, keep the full reference in a
programming topic and link from the user-facing explanation.

## Modes and terminology

Follow the distinctions established in `modes.texi`, `windows.texi`, and
`commands.texi`:

| Term            | Use it for                                                   |
| --------------- | ------------------------------------------------------------ |
| Buffer          | The editable or displayed text and its associated state.     |
| Window          | An Emacs display area showing a buffer.                      |
| Frame           | The container of Emacs windows.                              |
| Point           | A position in buffer text; the cursor indicates it visually. |
| Mark and region | A saved position and the interval between it and point.      |
| Command         | A function callable interactively.                           |
| Function        | A callable programming interface, possibly noninteractive.   |
| User option     | A variable intended to be customized by users.               |
| Major mode      | The buffer's principal editing behavior.                     |
| Minor mode      | An additional behavior that can be enabled or disabled.      |
| Face            | Attributes used to display text.                             |

Describe enabling and disabling a minor mode and whether its scope is local or
global. A major mode is normally replaced with another major mode; “disable the
major mode” is usually misleading. Explain whether a command displays a buffer,
selects a window, or does both.

Introduce a new technical term with `@dfn{}` where it is defined. Later mentions
normally use plain prose. Use `@code{}` for actual Lisp symbols. Human-facing
mode names usually take forms such as “Text mode” and “Auto Fill mode”, while
command names are `@code{text-mode}` and `@code{auto-fill-mode}`.

## Voice and precision

Use present tense and active verbs. Address the reader as “you” when giving
instructions. State a condition and its consequence together. Prefer “If the
value is non-@code{nil}, …” to vague terms such as “truthy”.

Replace promotional or circular explanations:

> Demo Notes provides powerful and flexible note filtering capabilities.

with an observable task:

```texinfo
  To find notes about a topic, type @kbd{/} and enter a word from
their titles.  The list then shows only matching notes.
```

Avoid maintenance history, project discussions, future promises, and
implementation trivia unless they are needed for compatibility or diagnosis. Do
not turn the manual into a changelog. A version qualification is useful when
readers must choose between different supported behaviors.

Use emphasis sparingly for an actual distinction. `@dfn{}` introduces terms;
`@emph{}` stresses a word; `@strong{}` is not a substitute for a clear warning.
Retain a required warning near the operation whose consequences it explains.

## Examples and troubleshooting

Introduce an example with the situation it illustrates, then explain its result.
State the relevant environment: an initialization file, a particular buffer, a
shell, or a Lisp evaluation context. Avoid long examples that force readers to
distinguish the main idea from unrelated setup.

An example can be schematic, but must say so. Mark replaceable material with
`@var{}` and explain it. A purportedly runnable example must include its
prerequisites and use interfaces supported by the documented version.

Prefer small text displays over screenshots for textual output. `@point{}` can
show a position in a buffer without tying the example to a theme or frame size.
Preserve literal newlines and spacing when they are meaningful.

For diagnosis, begin with an observable symptom and a useful distinguishing
check. `trouble.texi` separates an incorrect display from incorrect buffer text,
then gives different recovery actions. Explain what a result tells the reader
and which action follows. Do not promise that an action is safe, reversible, or
data-preserving unless the behavior supports that claim.

## Source layout

GNU Emacs's source-tree `.dir-locals.el` sets `fill-column` to 72 and
`sentence-end-double-space` to `t`. The manual's ordinary prose commonly begins
with two spaces and continues at the left margin:

```texinfo
  A note list shows one entry for each note.  Each entry contains a
title and the date on which the note was last changed.

  You can visit a note by moving point to its entry and typing
@kbd{@key{RET}}.
```

Use that layout for new English prose in this style. For Chinese, use the
project's source width measured in display columns, natural sentence spacing,
and consistent spacing around Latin terms. Emacs's `string-width` can check
display width; character counts cannot. Keep block commands at the left margin.
Entries in tables and many definition bodies start without the two spaces; do
not mechanically indent every text line. Separate table entries with blank lines
when editing them, even though older source sometimes omits the separators.

Do not auto-fill Lisp, shell commands, literal output, or menus as prose. Break
long definition headers using Texinfo's continuation syntax. Do not break an
identifier or URL merely to satisfy a source-width check. A short menu label
with a long hidden target may exceed 72 source columns while displaying neatly
in Info.
