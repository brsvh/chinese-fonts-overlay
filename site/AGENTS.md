# Site instructions for agents

These instructions apply to `site/` and complement the repository's
[root instructions](../AGENTS.md). Paths below are relative to this directory
unless explicitly described as repository paths. Keep site-wide architecture,
data, and publication rules here; language skills provide implementation
techniques and focused verification guidance.

Inspect implementation and documentation together. The build requirements below
state the intended contract; a planned target must not be reported as verified.
Follow later explicit user decisions when they change the contract.

## Ownership and layout

`site/` is the website subproject. It belongs to the tools private flake,
registers through `default.nix` in the root flake's `private.modules`, and
exposes `apps.site`. Preserve argument forwarding through
`nix run .#site -- ...`, including local port selection and build-only
operation. For Nix changes read
[nix-coding](../.agents/skills/nix-coding/SKILL.md) and its style reference
first.

| Location                                                        | Maintained responsibility                                               |
| --------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `bootstrap`, `configure.ac`, `Makefile.am`, `build-aux/`, `m4/` | GNU Autotools entry points and build support.                           |
| `module/chinese-fonts-overlay-site/`, `scripts/`                | Native Guile modules and command entry points.                          |
| `src/`                                                          | Native C font inspection, rendering, and image validation.              |
| `web/`                                                          | Hoot browser Scheme, static HTML, and minimal JavaScript host bindings. |
| `data/`                                                         | Reviewed language names and multilingual sample data.                   |
| `tests/`                                                        | Native Guile tests and small, redistributable fixtures.                 |

Use Guile for handwritten site automation, including bootstrap helpers, catalog
generation, coverage scanning, preview orchestration, local serving, and test
drivers. Generated Autoconf shell code and short Make recipes invoking tools are
normal parts of Autotools. Do not move maintained policy into shell recipes,
Python, or JavaScript to avoid a Guile implementation. The skill directories'
optional educational harnesses are separate from site sources.

## Build, installation, and distribution

- Follow the root Makefile formatting rules for `Makefile.am`: at most 80
  columns, with literal Tabs for recipe prefixes. Run mbake with the root
  `.bake.toml` explicitly when working from this directory. Use Automake/build
  checks for its syntax; mbake's GNU make validation is not an Automake check.
  Regenerate `Makefile.in` and configured Makefiles instead of formatting them.
- Maintain `configure.ac` and `Makefile.am`; regenerate `configure`,
  `Makefile.in`, and helper files through bootstrap. Check dependencies through
  configure/pkg-config using the repository's selected environment. Nix supplies
  dependencies and wraps the same build; it must not duplicate build logic.
- Support a separate build directory and read-only source tree after bootstrap.
  Use `srcdir`/build-directory paths deliberately; generated Wasm, copied
  runtime helpers, native binaries, logs, caches, and public output belong in
  writable build/output locations. Do not assume the invocation directory is
  `site/`.
- Keep ordinary compilation independent of downloading every font. Full catalog
  generation consumes explicitly evaluated metadata and private font inputs;
  ordinary fixture checks must not require the full font collection or network.
- Maintain `make`, `make check`, site generation/serving targets, installation
  and uninstall, `clean`/`distclean`, and distribution rules as the build is
  implemented. Use Automake's `foreign` mode. Keep `README` minimal and use Org
  syntax with a first-line `-*- mode: org; -*-` declaration. Include a short
  overview and local startup command; keep detailed development instructions in
  `../docs/development.md`, without end-user installation instructions. Do not
  add `AUTHORS`, `ChangeLog`, `COPYING`, `INSTALL`, or `NEWS` under `site/`. The
  repository-root license still applies. Source archives must build without Git
  or generated change history.
- Support `prefix` and `DESTDIR` staging. Installed commands must find modules,
  data, native tools, and matching Hoot resources without the source checkout or
  a recorded build-directory path. A source archive must bootstrap/configure and
  build under its documented workflow without a Git checkout; accept an explicit
  source revision for permanent links when Git metadata is absent. Help/version
  commands should work without font inputs or a repository checkout. Keep module
  loading free of build and server-start side effects.
- For build-system changes, exercise out-of-source build, relevant checks,
  staged installation, and `make distcheck` once those targets are available. Do
  not substitute a successful Nix evaluation for executing the built command.
  Report unavailable or failing targets explicitly rather than skipping them and
  claiming completion.

Use the current flake inputs for dependency versions; updating them is a
separate task unless requested. Local functionality precedes styling and CI. Do
not add deployment or change the separate CI preview sample configuration
(`../tools/generate-font-preview-images/sample-keys.nix`) during site work.

## Data ownership

Package facts live in `package.nix` under `passthru.fontInfo`. Read the actual
schema in [`../lib/font-info.nix`](../lib/font-info.nix) and the
[development documentation](../docs/development.md) rather than inventing a
second per-package index. Vendor/style/license-cost values are reviewed
metadata; languages are a sorted, unique list scanned from actual font coverage.
Preserve optional per-package notices. Exclude aggregate packages using
`isFontAggregate` supplied by the combining helper.

Coverage maintenance and a normal site build have different effects. A build
does not rewrite package definitions. An explicit coverage update scans all
selected inputs before writing, changes only language lists, and preserves other
metadata. Its check mode must fail when recorded coverage is stale. Package
language coverage is a union; an individual preview still needs glyph coverage
in that face for the selected sample.

Language-to-sample mappings and Simplified Chinese language labels are
maintained in `data/`. Keep samples in their actual languages, Chinese regional
names in the project's script/region format, and source attribution with the
sample data. Do not restore a per-package sample selector or require Babel at
runtime. Use stable keys for machine-readable categories and existing Chinese
labels for the interface, including 未知 for unknown metadata.

## Publication and expensive work

The website is fully static. Publish generated HTML, public metadata JSON,
matching Hoot/Wasm and host assets, and transparent PNG previews. Do not publish
original font files, private renderer manifests, local source paths, or build
caches. All fonts use fixed image previews; `redistributable` remains metadata,
not permission to reintroduce browser text entry or webfont delivery.

Keep every supported face, collection member, weight, and named variable
instance. Use the original font formats without conversion or subsetting. Select
images from the language filter; never disguise a missing sample with another
language or a fallback font. Source links use a full commit revision and the
package's `package.nix` GitHub page.

Separate discovery, validation, rendering, and publication. Treat subprocess
output as data, validate its shape, and check exit status. Pass argument vectors
instead of interpolating filenames into shell commands. Keep stdout machine
readable and diagnostics on stderr for tool protocols. Distinguish JSON false,
null, empty objects, and empty arrays at native/Hoot boundaries.

Reuse valid caches for the large corpus. Cache identity must include the
semantic inputs that can change output: font content, face/instance, sample, and
relevant inspection/rendering configuration. Bound renderer concurrency and
propagate worker failures. Publish complete validated outputs through a
staging/replace strategy appropriate to the artifacts; a failed build must not
leave apparently successful partial manifests or discard the previous site.
Clean only task-owned temporary/build artifacts, not unrelated user caches.

## Verification scope

Test final, observable functionality and supported user workflows, not
intermediate development steps, historical implementations, or private helper
structure. Keep the suite minimal: retain only tests that protect a necessary
behavior or a distinct failure boundary. Consolidate overlapping coverage and
remove obsolete assertions instead of accumulating tests for each refactor. Do
not test trivial wrappers, fixed schema numbers, incidental markup hooks, or
internal data layouts for their own sake. Use otherwise valid fixtures when
testing rejection, and check the intended diagnostic rather than accepting any
exception. Test helpers should prepare inputs or return results; keep assertions
in the test cases themselves.

Prefer small licensed fixtures for static fonts, collections, variable
instances, Unicode, missing glyphs, and invalid/transparent PNGs. Match tests to
the changed contract: native font tools, Guile transformations and CLI exit
status, actual HTTP responses, or Hoot interactions in a browser. Use SRFI-64
for native drivers and preserve failures in the process exit status.

For a migration, compare meaningful metadata, faces, sample selection, and
public artifact contents against the existing output. Counts alone do not
establish parity. Reuse full-corpus output and caches where valid; regenerate
the corpus only when a changed contract needs it. State what ran and which parts
remain unverified.
