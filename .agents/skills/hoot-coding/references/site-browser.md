# Browser interactions

Read when changing filters, URL state, asynchronous previews, or the Hoot host
bridge. Obtain the schema, selectors, labels, and default choices from the
target application. The examples below describe interaction mechanisms, not a
font-site architecture to impose on another project.

## Scheme and host responsibilities

Keep application policy in the layer the project assigns to it. In a Hoot
application, Scheme can own filtering, selection, state transitions, and user
messages while JavaScript supplies narrow DOM, URL, fetch, and image bindings.
Do not duplicate policy or metadata tables in the bridge.

`Scheme.load_main`, typed imports, callbacks, and reflection must agree with the
selected compiler/runtime. Build the application and matching helper assets
through the project's build system, whether Autotools or another system. Resolve
assets under its actual deployment base; never copy a runtime from an old skill
fixture merely because the filenames match.

## Filters and URL state

Preserve the application's distinction between absent, empty, and explicit query
parameters. For example, a language filter may use absence for a default
language and an empty value for all languages; neither the key spelling nor that
default is a universal Hoot rule. Reset and Back/Forward should restore the
project's defined state. Keep machine keys stable and use its localized labels.

Use actual coverage when selecting previews. A package-level match need not mean
every item has content for that selection. If a language-specific item is
missing, retain the intended missing state instead of silently substituting an
unrelated item. Preserve the required item variants and combined filters.

## Asynchronous state and ownership

Respect the product's preview format and access rules. A fixed-image catalog
should not acquire editable text or font-file delivery merely as part of a Hoot
refactor. Other applications retain their own preview contract.

When a selection changes during a fetch or image load, stale completion must not
overwrite the new state. Tie requests and callbacks to the active owner or
generation; handle both success and failure. Avoid duplicate listeners and
repeated downloads of a valid cached result. Preserve existing loading, missing,
failure, retry, success, and fallback behavior and accessible labels. Do not add
redundant status text when the product intentionally hides it.

## Verification

Compile with the selected toolchain, then exercise changed interactions in an
available browser. Relevant cases include default and explicit selections, empty
results, missing content on one item, combined filters, URL restoration, rapid
changes, failed loading/retry, and failed enhancement. Select cases for the
change instead of rerunning a full matrix for text-only edits. Native tests and
host stubs cannot establish actual DOM events or browser resource loading;
report unavailable browser checks explicitly.
