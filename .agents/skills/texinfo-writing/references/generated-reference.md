# References generated from source data

Use this guide when a manual combines authored chapters with a package catalog,
command inventory, or other evaluated source data.

## Choose the authoritative source

Keep purpose, examples, tradeoffs, and troubleshooting in authored prose.
Extract factual names, versions, supported values, and source locations from the
implementation when that avoids a second maintained copy. Evaluation does not
establish the intended semantics of an arbitrary function.

A Nix project may expose overlays, package scopes, derivations, and plain
functions without providing configuration modules. Document the interfaces it
actually exports. Use module-option extraction only for a real module system
interface; do not introduce modules merely to generate a manual. Do not infer
types or defaults by parsing assertion messages.

Select a small JSON-compatible record for each documented entry. Evaluate
against the project's pinned inputs and explicit target system, without
realizing font or package outputs. Avoid stringifying derivations and publishing
store paths, local source directories, or private scan reports. Represent
package references by their complete public attributes. Record source paths
relative to the repository and construct revision-pinned links.

Aggregate membership must come from the composition function's actual input, not
a separately maintained list or a parsed build command. A package list and a
rendered preview selection are different scopes; a complete reference must not
accidentally shrink to the current preview selection.

## Compose the manual

Use stable source identities for nodes and anchors, and human-facing names for
headings and menu labels. Group entries according to the product's meaningful
categories. Generate menus and indexes from the same entries. Include
hand-written introductions where they provide useful context; do not create
empty files merely to mirror every category.

Write generated fragments and intermediate data to the build directory. Keep one
owner for the generation rules and make the website consume those outputs. A
generated field is not a substitute for editorial review: upstream English
descriptions, missing explanations, and ambiguous wording still need an explicit
authoring decision.

Treat extracted strings as text. Escape `@`, `{`, and `}` for Texinfo, including
inside examples. Handle URL arguments and line breaks deliberately; do not allow
arbitrary metadata to inject Texinfo commands or includes. Use the format's
structural markup for paragraphs, lists, and references.

Preserve the manual's chosen license. Emacs-derived writing conventions do not
require GFDL licensing, invariant sections, or copied Emacs prose. Generated
third-party descriptions and quoted license text retain their own attribution
and permissions; do not relabel them by changing a header.

## Verify the result

Check complete and unique coverage, including deliberately separate variants and
aggregates. Build both Info and the requested HTML form. Follow menus, package
links, and index entries in the readers; inspect non-ASCII headings, long
attributes, and special characters. Exercise an incremental rebuild and an
independent output directory. Keep failed output from replacing a previous
complete manual or website.
