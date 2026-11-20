# Website Maintenance Guidelines

This file applies to `site/` and supplements the
[root guidelines](../AGENTS.md). Unless stated otherwise, paths are relative to
this directory. Review the implementation and documentation together; do not
describe planned capabilities as verified. The user's later explicit decisions
take precedence over these conventions.

## Structure and Responsibilities

The website belongs to the private `tools` flake. `default.nix` registers it in
the root flake's `private.modules` and provides `apps.site`. Preserve argument
forwarding through `nix run .#site -- ...`, including port selection and
build-only mode. Before editing Nix, read
[nix-coding](../.agents/skills/nix-coding/SKILL.md) and its style guide.

| Location                                                 | Responsibility                                           |
| -------------------------------------------------------- | -------------------------------------------------------- |
| `bootstrap`, `configure.ac`, `Makefile.am`, `build-aux/` | Autotools entry points and build support                 |
| `module/chinese-fonts-overlay-site/`, `scripts/`         | Native Guile modules and command entry points            |
| `src/`                                                   | Native font parsing, rendering, and image validation     |
| `web/`                                                   | Hoot Scheme, static HTML, and minimal browser interfaces |
| `data/`                                                  | Verified language names and multilingual sample text     |
| `tests/`                                                 | Functional tests and small redistributable fixtures      |

Use Guile for handwritten website automation, including bootstrap helpers,
catalog generation, coverage scanning, rendering orchestration, local serving,
and test drivers. Autoconf-generated shell code and short Make invocations are
normal build support; do not move maintenance policy into shell, Python, or
JavaScript to bypass the Guile implementation. Optional validation scripts in
skill directories are not website source code.

## Interface and Styling

Before changing website components, styles, themes, or Tailwind CSS and daisyUI
build configuration, use
[daisyui-coding](../.agents/skills/daisyui-coding/SKILL.md). This also applies
to Scheme/SXML-generated HTML and website dependency configuration outside
`site/`. When Guile, Hoot, or Nix is involved, also follow the corresponding
skills specified in the root guidelines.

When integrating or upgrading dependencies, check that the official skill and
component sources referenced by the skill match the project's dependency
versions. Prefer tools provided by the currently locked Nixpkgs. Pin missing
dependencies separately by version and hash; do not update the lock file merely
because an online example uses the latest version.

The current dependencies are the Tailwind CSS 4.3.4 standalone compiler and the
daisyUI 5.7.39 plugin package. Nix supplies dependencies, and Autotools compiles
CSS; do not introduce a Node project or a runtime CDN. Use the standard Modus
Operandi theme and TsangerYuYangT W02 and W03 for the interface font. New
complete class names must be discoverable through the CSS entry point's explicit
source scanning. Pass continuous preview dimensions through CSS variables. Keep
filtering, URL state, and asynchronous loading policy in Hoot; browser
interfaces provide only the necessary host operations.

## Building, Installation, and Distribution

- `Makefile.am` follows the root guidelines' 80-column and tab rules. Explicitly
  use the root `.bake.toml` with mbake. Its GNU Make validation does not replace
  Automake checks. Do not format generated files.
- Maintain `configure.ac` and `Makefile.am`, and regenerate configuration and
  auxiliary files through bootstrap. configure/pkg-config checks dependencies in
  the pinned environment. Nix wraps the same build rather than duplicating build
  logic.
- Support separate build directories and source directories that are read-only
  after bootstrap. Write Wasm, runtime assets, binaries, logs, caches, and
  website output to writable directories. Distinguish `srcdir` from the build
  directory correctly; do not assume the caller is in `site/`.
- Normal compilation and tests must not require downloading the entire font
  collection. Full catalog generation explicitly consumes metadata and private
  font inputs; small tests must not depend on the network.
- Keep `make`, `make check`, website generation and serving, installation and
  uninstallation, `clean`, `distclean`, and distribution targets working. Use
  Automake's `foreign` mode. Documentation uses Chinese Org format, with the
  mode declaration retained on the first line of `README`. Keep local operation,
  build, and data-maintenance instructions in [README](README); do not restore
  separate development documentation.
- Do not add `AUTHORS`, `ChangeLog`, `COPYING`, `INSTALL`, or `NEWS` in this
  directory. The repository's root license still applies. Source distributions
  must build without Git or a generated change history.
- Support `prefix` and `DESTDIR`. Installed commands must find their modules,
  data, native tools, and matching Hoot resources without relying on a source
  checkout or a recorded build directory. Accept an explicit source commit ID
  when Git is unavailable. Help and version commands must not require font
  inputs or a repository. Loading a module must not start a build or server.
- After changing the build system, perform a build in a separate directory, the
  relevant checks, a staged installation, and `make distcheck`. Successful Nix
  evaluation does not replace actual execution. Report verification that failed
  or could not be completed accurately.

Use dependency versions from the current flake inputs; lock-file updates are a
separate task. Local functionality takes priority over styling and CI. The
planned website URL is `https://brsvh.github.io/chinese-fonts-overlay/`; the
site is not currently deployed. Without an explicit request, do not add
deployment configuration or modify the separate CI preview sample table at
`../tools/generate-font-preview-images/sample-keys.nix`.

## Data Ownership

Maintain package information only in `package.nix` under
`passthru.chinese-fonts-overlay-site`. Read the
[actual schema](../lib/font-info.nix) and [maintenance instructions](README); do
not create a separate per-package index. Font vendors, styles, and license costs
are verified manually. Languages come from font coverage scans and must be
sorted and unique. Preserve per-package notices, and exclude aggregate packages
using the `isFontAggregate` flag supplied by the composition functions.

Styles are overlapping labels, not mutually exclusive categories. Preserve all
verified styles in a package, including styles reached through variable axes.
For example, Gothic faces normally use both `hei` and `sans`, while Song faces
use `serif` and `song`. Use `rounded` for rounded typefaces, `handwritten` for
handwriting, and `symbol` for icon, emoji, or dedicated symbol fonts.
Calligraphic or decorative handwriting may also use `cal` or `art`; do not use
either as a catch-all for handwriting. Prefer publisher descriptions, then
inspect actual preview glyphs across relevant faces. Do not infer the whole
package's style from its name or first face. Ask the maintainer when neither
source resolves a classification; `unknown` must stand alone when evidence is
insufficient.

The required `displayName` is the publisher's family or product name, verified
against its homepage or release documentation. Prefer the publisher's local name
when available. Do not concatenate weight names or duplicate translated aliases.
Preserve distinctions between separately packaged regions, families, and
variable-font variants; a package containing multiple independent families must
identify them. Maintain this name in the package rather than deriving it from
font file names or the first face's full name.

The optional boolean `embedding` takes precedence over `meta.redistributable`;
when omitted, derive it from the latter, defaulting to false if that is also
absent. Audit embedding font files in software, websites, or devices against the
package's license and the publisher's original terms. Free commercial use,
rendered output, or document-only embedding does not establish this permission.
Do not mark permission as granted when it requires a separate purchase or
application, or when the available terms do not establish it. A true value still
requires compliance with applicable attribution, license, source availability,
and font replacement conditions. Omit the field when the default is correct;
record overrides and special conditions in package notices with source links.
The public catalog contains the final boolean; the frontend must not infer it
again. Open-source and proprietary categories use the license's explicit `free`
value; missing information remains unknown.

Default filters are Simplified Chinese, sans-serif, all vendors, all costs, and
open-source licenses. Font embedding is unchecked by default. Combine choices
within a category with OR and different categories with AND; an empty selection
means no matches. Reset restores these defaults. Select-all checkboxes include
collapsed options and reflect partial selection. URL state and browser Back and
Forward must restore the same selections.

Normal website builds do not rewrite package definitions. An explicit coverage
update first scans all selected inputs; only after success does it write the
language lists, preserving other metadata. Check mode fails when recorded data
is stale. Package language coverage is the union across its faces, but each
preview must still use sample text actually supported by that face.

Maintain language-to-sample mappings and Simplified Chinese language names in
`data/`. Preserve the samples' actual languages, the Chinese regional naming
format, and source notes. Do not restore per-package sample selectors or add a
Babel runtime dependency. Use stable machine keys for categories and retain
Chinese UI labels, including the label for unknown values.

## Output and Expensive Operations

The website is entirely static, publishing HTML, CSS, public metadata JSON,
matching Hoot/Wasm assets, and transparent lossless WebP images. Use fixed
images for all catalog fonts; do not publish their original files, private
rendering manifests, local paths, or caches. Interface fonts are the sole
exception: ship the original TsangerYuYangT W02 and W03 TTF files and their
license statement with the site. Use `redistributable` for status display and
the default value of `embedding`; do not use it as grounds to restore live
previews of user-entered text.

Render previews in memory with Pango/Cairo and encode them directly with
libwebp. Cache and publish WebP only. Use lossless encoding with quality 75,
method 6, and exact transparent pixels; correctly convert Cairo's premultiplied
ARGB pixels before encoding. In lossless mode, quality controls compression
effort, not pixel fidelity. Validate decoded pixels, transparency, and nonblank
content before publication. Include rendering and encoding configuration in
cache identities.

Preserve all supported faces, font collection members, weights, and named
variable-font instances. Use the original formats directly; do not convert or
subset fonts. Show samples for the selected languages. Do not hide missing
samples by substituting another language or a fallback font. Source links must
point to the GitHub page for `package.nix` at a full commit ID. Footer links for
website source code, the commit, and the website license must use that same
commit. Scale images to the actual preview size; allow horizontal scrolling when
space is insufficient instead of shrinking them to the container width.

Handle discovery, validation, rendering, and publication separately. Parse
subprocess output as data and validate its structure and exit status. Pass
argument arrays rather than interpolating filenames into shell commands. Keep
tool-protocol standard output machine-readable and send diagnostics to standard
error. Distinguish JSON false, null, empty objects, and empty arrays explicitly
across native Guile and Hoot.

Reuse valid caches. Cache identifiers must include the font content, faces and
instances, sample text, and parsing and rendering configuration that can affect
the output. Limit rendering concurrency and propagate worker failures. Validate
all output successfully in a staging directory before replacing the published
output; preserve the previous complete website on failure. Clean up only
temporary artifacts owned by the current task, not unrelated caches.

## Verification Scope

Test only final observable functionality and supported user actions, not
intermediate development steps, historical implementations, or private helper
structures. Keep tests minimal, covering only necessary behavior and distinct
failure boundaries. Merge overlapping coverage and remove obsolete assertions;
do not accumulate tests for every refactor. Do not separately test trivial
wrappers, fixed schema numbers, incidental page hooks, or internal layouts. When
testing rejection, all other input conditions must be valid. Check the expected
diagnostic; do not treat an arbitrary exception as success. Test helpers only
prepare inputs or return results; keep assertions in test cases.

Prefer small, licensed fixtures covering static fonts, font collections,
variable instances, Unicode, missing glyphs, and invalid or nontransparent
images. Choose verification appropriate to the changed boundary: native tools,
Guile transformations and command exit status, real HTTP responses, or browser
interactions. Native tests use SRFI-64, and failures must be reflected in the
process exit status.

During migrations, compare actual metadata, faces, sample selections, and public
artifacts, not just counts. Reuse full-catalog output and caches when valid;
rebuild the entire font collection only when the change requires it. Clearly
report what has and has not been verified.
