# Validation of a Texinfo writing change

Use the target project's documentation commands when they exist. This guide is
an author workflow, not material to paste into a user manual. Match checks to
the change: a small prose edit needs the affected manual's outputs and nodes
checked; a shared navigation or formatting change needs the affected manuals
checked consistently.

## Check content before rendering

Verify the source of each factual claim: the implementation, public command
help, declared dependencies, or the relevant upstream manual. In particular,
check default keymaps, whether a symbol is interactive, option defaults,
buffer-local state, setter effects, and timing of hooks or completion.

Resolve obsolete names and contradictory descriptions. Check examples against
the documented minimum version, not only the author's installed version. Do not
execute a destructive or externally mutating example solely to verify its
wording. The bundled example manual describes imaginary interfaces and is
intended for markup and navigation validation only.

## Build both Info and HTML

The shell examples below assume a POSIX shell, `mktemp`, and GNU Texinfo's
`makeinfo` on `PATH`. `texi2any` is an alternative name for the processor. In
another shell, use its normal temporary-directory facility and pass the
resulting output paths to the same Texinfo options. If a required tool is
unavailable, report which checks could not be performed.

For a standalone file, run from its source directory:

```sh
texinfoCheckDir="$(mktemp -d)" || exit 1
makeinfo --no-split --output="$texinfoCheckDir/manual.info" manual.texi
makeinfo --html --no-split --output="$texinfoCheckDir/manual.html" manual.texi
```

The temporary directory is chosen by `mktemp`, honoring `TMPDIR` when set; the
commands do not assume a fixed filesystem location. Keep the directory until the
generated outputs have been inspected.

Add the required include paths, project defines, and external-reference mapping
from the actual build. Do not suppress warnings globally with `--no-validate`.
Resolve diagnostics involving duplicate nodes, missing menu targets,
inconsistent hierarchy, unclosed commands, and bad references. Inspect index
warnings instead of deleting entries merely to silence them.

For the bundled specimen, from the skill directory:

```sh
texinfoCheckDir="$(mktemp -d)" || exit 1
makeinfo --no-split \
  --output="$texinfoCheckDir/demo-notes-example.info" \
  references/example-manual.texi
makeinfo --html --no-split \
  --output="$texinfoCheckDir/demo-notes-example.html" \
  references/example-manual.texi
```

When testing a stylesheet requested by the project, pass `--css-ref` with its
external URL. Do not embed a copy or add a theme as part of validation. If split
HTML is a deliverable, build that too: the unsplit output does not exercise
every generated filename or cross-page link.

## Inspect Info as a reader

Open the generated file with Emacs Info, for example by using `C-u M-x info` and
supplying its absolute filename. Inspect at least:

1. Top: purpose, copying notice, and absence of unnecessary title/version
   repetition in the introduction.
2. Menus: labels, descriptions, order, wrapping, and actual target nodes.
   Inspect with normal reference hiding, not only the raw Info source.
3. Navigation: follow a menu item, use Up, Next, and Previous, and follow a
   cross-reference back into the affected material. Check that these operations
   reach the intended topics.
4. The changed topic: paragraph shape, examples, key notation, and complete
   definitions or tables.
5. Indexes: look up a concept and relevant public symbols; follow entries and
   confirm that they reach substantive explanations. Include hooks, faces, and
   mode-qualified keys when those are part of the change.

External references need a separate target check. For example, visit
`(emacs)Hooks` and `(emacs)Saving Customizations` for this specimen. If an
upstream manual is absent, verify its node against an available authoritative
source or report that the target was not checked. A successful build does not
validate an external manual's contents.

Use an available Emacs session or Info reader. If the target project requires an
existing session, follow its connection and state-preservation instructions.
This skill assumes no Emacs server or particular display backend. If an
interactive reader is unavailable, report that limitation and use available
noninteractive checks without claiming a live inspection.

Batch Emacs with Info can check navigation, but does not establish how a menu
looks in a live window with hidden references. For visual inspection, use an
available session and leave the reviewed material accessible when that is part
of the user's workflow. Capture only the relevant visible region and preserve
point/window state during capture.

## Inspect HTML and other requested formats

Open the rendered HTML in a browser or an available HTML viewer. Check the same
affected topics, plus:

- Heading hierarchy and anchor destinations.
- Definition terms and bodies, lists, tables, and preformatted examples.
- Internal and external links, including cross-manual reference mappings.
- Top and copying notice: repeated text can be format-dependent.
- A normal narrow viewport as well as a wider one when changing layout.

Reading generated HTML source or parsing its links is useful, but is not a
visual review. State the distinction if a renderer is unavailable. Build and
inspect PDF or printed output when requested or when the edit concerns
pagination, TeX conditionals, or other print behavior.

## Source review and completion

Check newly edited prose for the project's paragraph indentation, display width,
language-appropriate sentence spacing, semantic markup, and escaping. The
English specimen uses 72 columns and double sentence spaces; do not apply its
sentence spacing mechanically to Chinese. Exclude menu targets, long indivisible
names, literal examples, and definition continuations from a naive line-length
fix. Check that an automatic formatter has not changed literal code or output.

For a shared issue, inspect all affected manuals rather than stopping at the
first passing file. Distinguish newly introduced defects from unrelated existing
ones. Report what changed, what outputs were built and inspected, and any
unresolved diagnostic or inaccessible target. Keep build artifacts outside the
source tree unless the project intentionally tracks them.

For generated references, compare source identities with documented entries.
Check missing or duplicate entries, stable anchors, literal text containing
Texinfo metacharacters, and links under the real website path prefix. Verify
that generation does not realize unrelated packages or expose local paths.
