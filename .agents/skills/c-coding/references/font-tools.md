# Native font tools

Read when changing native font tools or their scripting-language boundary. Use
the actual FreeType, Fontconfig, Pango, Cairo, and GLib interfaces supplied by
the project; do not replace inspection or shaping with filename heuristics.

## Input and identity

The pipeline accepts original TTF/OTF files and supported TTC/OTC collections.
Enumerate collection members from font data, including a one-member collection;
an extension or a face count alone does not establish container identity. Keep
collection indices, variable named-instance coordinates, and display labels
separate. Do not collapse distinct weights or instances because names match.

Preserve the project's family/style/full-name selection and Unicode decoding
policy when replacing an inspector. Review cmap selection and symbol-font
mapping deliberately; blindly using whichever charmap is initially active may
change coverage. Decode SFNT names using their platform/encoding information,
with explicit malformed-input behavior. Do not apply locale byte operations to
Unicode names or silently guess language from the font's vendor.

Keep coordinate units and numeric serialization stable across native and
scripting boundaries. Validate font/table errors, face indices, bitmap
dimensions, and allocation arithmetic before consuming them. Use matching
destructors for FreeType libraries/faces/variation data, Fontconfig objects,
Pango objects, GLib data, and Cairo contexts/surfaces, including partially
initialized error paths.

## Rendering and publication evidence

Render the requested face and instance using its original file. Prevent a system
fallback font from silently satisfying absent glyphs. Preserve shaping for
complex scripts and the selected direction/layout; a Unicode cmap alone does not
prove a sample can be correctly shaped.

Preserve the requested background and output format. For transparent PNG
previews, clear the surface before drawing and preserve alpha. Verify that the
sample is nonempty and not clipped, and detect opaque output when transparency
is required. Check dimensions and transparency using decoded pixels, not the
filename or the presence of an alpha channel. Keep failures distinct from the
explicit unsupported-sample outcome.

Keep native font operations separate from orchestration and metadata policy.
When the project assigns language selection, caching, workers, manifests, and
publication to Guile or another scripting layer, preserve that boundary. Do not
move license classification or package-manager invocation into the C renderer as
a side effect of a native-tool change. Use a documented machine-readable
protocol for tool results and stderr for diagnostics. Escape names/text
correctly in the chosen encoding; the consumer reads and validates the data
without evaluating it.

## Focused checks

For inspection changes, compare static faces, collection members, and named
instances against known fixture expectations, including non-ASCII names and the
relevant coverage cases. For rendering changes, exercise a real native render,
selected-face identity, unsupported glyphs, and decoded transparent PNG content.
For resource changes, exercise the relevant failure cleanup with compiler
diagnostics and sanitizers where practical. Avoid requiring the full font corpus
or the optional Rust reference harness for a small native change.
