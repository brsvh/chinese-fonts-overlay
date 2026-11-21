# Website Maintenance Guidelines

This file applies to `site/` and supplements the
[root guidelines](../AGENTS.md). Unless stated otherwise, paths are relative to
this directory. Review the implementation and documentation together; do not
describe planned capabilities as verified. The user's later explicit decisions
take precedence over these conventions.

## Structure and Responsibilities

The website uses one handwritten `Makefile`. Nix supplies the development shell,
pinned tools, interface assets, and font inputs. There is no website app or
server package. `make` builds the static website, `make check` runs small
fixture tests, and `make serve` serves an existing public directory.

| Location                                         | Responsibility                                                |
| ------------------------------------------------ | ------------------------------------------------------------- |
| `Makefile`, `build-aux/`                         | Build dependencies and small build helpers                    |
| `scripts/`, `module/chinese-fonts-overlay-site/` | Guile build entry points, rendering orchestration and serving |
| `src/`                                           | Native font inspection, rendering and image validation        |
| `web/`                                           | Hoot interactions, static HTML and styles                     |
| `data/`                                          | Verified language names and multilingual sample text          |
| `tests/`, `tests/fixtures/fonts/`                | Website tests and CC0 font fixtures                           |

Use Guile for handwritten website automation. Keep dependency ordering in Make
and website transformations and artifact validation in Guile. CI scheduling,
credentials and remote publication belong to `../ci/` and use JavaScript
modules. Short Make recipes are normal build support. Loading a module must not
start a build or server.

All changes to `package.nix` belong to font-package maintenance outside this
directory. The standalone `tools/update-font-languages/` tool owns language
scanning and updates. Website builds, tests and serving never rewrite packages.

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
daisyUI 5.7.39 plugin package. Nix supplies dependencies, and Make compiles CSS;
do not introduce a Node project or a runtime CDN. Use the standard Modus
Operandi theme and TsangerYuYangT W02 and W03 for the interface font. New
complete class names must be discoverable through the CSS entry point's explicit
source scanning. Pass continuous preview dimensions through CSS variables. Keep
filtering, URL state, and asynchronous loading policy in Hoot; browser
interfaces provide only the necessary host operations.

## Building and Serving

- Maintain `Makefile` directly, following the root 80-column and tab rules. Use
  the root `.bake.toml` with mbake. Do not restore Autotools, installed website
  commands or a second Nix build implementation.
- The default target builds the complete website into `BUILD_DIR/public`. Keep
  native compilation, browser assets, input preparation, preview rendering and
  final publication separate. Reuse unchanged previews for page-only edits.
- `make check` uses small licensed fixtures and must not fetch the font
  collection. `make serve` only needs Guile and the selected public directory;
  it never compiles assets, prepares inputs or rebuilds the website.
- `make release` packages existing public output without rebuilding it. Require
  an explicit source revision matching the catalog and a new release directory.
  Verify the two interface fonts and their license against the declared build
  inputs. Release archives contain only regular files from the public allowlist,
  remain below the Pages size limit and carry a SHA-256 manifest. Validate that
  manifest and the archive before making extracted output available to deploy.
- Support `BUILD_DIR` outside the source tree, with read-only sources and an
  explicit `SOURCE_REVISION` when Git is unavailable. Keep intermediate files,
  native binaries, test logs and public output beneath the build directory.
- Preserve preview caches across `make clean`. `make clean-cache` explicitly
  clears the renderer's owned cache entries. Never remove unrelated files or
  treat the repository itself as a build or cache directory.
- Refresh inputs from the current source tree when package definitions, locks,
  catalog rules or the set of packages changes. Do not freeze metadata when
  entering the development shell. Explicit `CATALOG` and `PREVIEWS` JSON inputs
  support offline builds without Nix; both must be supplied together.
- After build changes, exercise clean and incremental builds, parallel Make, an
  independent build directory, small tests and real HTTP responses. Check
  failure preservation and that serving does not trigger a build. There is no
  installation or source-distribution contract; the deliverable is `public/`.
- Keep user instructions in [README](README), in concise Chinese Org format. Do
  not add separate development documentation or generated change histories.

Use dependency versions from the current flake inputs; lock-file updates are a
separate task. Local functionality takes priority over styling and CI. The
website URL is `https://brsvh.github.io/chinese-fonts-overlay/`. Do not change
deployment configuration without an explicit request. Preview generation belongs
to the website build; do not restore separate image publication branches.

## CI Publication

CI calls the existing Make targets and the archive command interface. Keep
platform-independent packaging and validation here; maintain Hercules and GitHub
publication rules in the root `AGENTS.md` and their implementation in `../ci/`.
Website modules must not handle hosting credentials or remote state. The
`buildSite` Effect transfers validated output through Garage; the `deploy`
workflow downloads and publishes it. Keep the two-version retention policy and
S3 access in `../ci/`, independent of archive generation and font caching.

## Data Ownership

Read package metadata from `passthru.chinese-fonts-overlay-site` using
[the schema](../lib/font-info.nix). Package-maintenance rules belong to
[root guidelines](../AGENTS.md) and the
[contribution guide](../.github/CONTRIBUTING.md). Do not create another
per-package index. Exclude packages marked `isFontAggregate`.

Resolve optional `embedding` against `meta.redistributable`, defaulting to false
when both are absent. Publish the final boolean rather than inferring it in the
frontend. License category comes from the license's explicit `free` value;
missing information remains unknown. Preserve costs, notices and source links.

Default filters are Simplified Chinese, sans-serif, all vendors, all costs, and
open-source licenses. Font embedding is unchecked by default. Combine choices
within a category with OR and different categories with AND; an empty selection
means no matches. Reset restores these defaults. Select-all checkboxes include
collapsed options and reflect partial selection. URL state and browser Back and
Forward must restore the same selections.

Package language coverage is the union across its faces; each preview must still
use sample text actually supported by that face. Language coverage maintenance
and its detection rules belong to the standalone maintenance tool.

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
