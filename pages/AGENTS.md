# Website and Manual Maintenance Guidelines

Read the [root guidelines](../AGENTS.md) as well. This file covers website work,
including related configuration outside `pages/`. Paths below are relative to
this directory unless stated otherwise. User instructions belong in
[README](README).

## Boundaries

The handwritten `Makefile` coordinates preview and manual builds. Use
`make manual` and `make check-manual` in the lightweight manual shell. Nix
supplies pinned tools, interface assets and font inputs; there is no separate
website or server package. `make` builds, `make check` tests licensed fixtures,
`make serve` serves existing output, and `make release` archives it. Do not
introduce a second build system.

Keep dependencies in Make and transformations in Guile. Commands in `build-aux/`
load native modules from `module/`. Keep manual compilation, preview
preparation, shared presentation and HTTP serving in their respective modules.
`doc/` contains the Texinfo sources, `etc/` the preview inputs and language
data, and `src/` the native font tools. Browser Scheme, scripts, styles and
templates live in `web/`. Importing a module has no build or service side
effects.

CI scheduling, credentials, remote state and publication belong to JavaScript
modules in `../ci/`. Package definitions and language maintenance belong outside
`pages/`; website builds and tests must never rewrite packages.

## Inputs and builds

Read package metadata through `../packages/font-catalog.nix` and the shared
[validator](../packages/font-metadata.nix). Do not create a second package
index. Exclude `isFontAggregate` packages, preserve notices and sources, and
resolve embedding once in the public catalog. Missing license freedom is
unknown.

By default, build the complete catalog into `BUILD_DIR/public`. `PACKAGES`
selects complete overlay attributes for local previews. Validate every selector
before realizing fonts, reject unknown or aggregate attributes, deduplicate the
selection and include it in input fingerprints. Realize only selected font
inputs; changing or clearing the selection must invalidate prepared inputs.
Reject `PACKAGES` with explicit `CATALOG` and `PREVIEWS`.

Separate native compilation, browser assets, input preparation, rendering and
publication. Refresh inputs when definitions, locks, catalog rules or package
membership change. Do not freeze data when entering a shell. Explicit `CATALOG`
and `PREVIEWS` must be supplied together. For builds without Nix, also supply
`REFERENCE` with complete manual metadata or `MANUAL` with an already compiled
manual. Never derive manual coverage from a selected preview catalog.

Support independent build directories, read-only sources and an explicit
`SOURCE_REVISION` without Git. Keep intermediates and test logs under
`BUILD_DIR`. `make serve` requires only Guile and the selected public directory;
it must not prepare inputs or rebuild. `make clean` preserves preview caches;
`make clean-cache` removes only the renderer's owned entries.

## Interface and data

Use [daisyui-coding](../.agents/skills/daisyui-coding/SKILL.md) for components,
styles, themes and their build configuration, including generated SXML. Follow
the applicable Nix, Guile or Hoot skills too. Use locked dependencies, verify
upstream guidance when upgrading, and do not update locks merely to match an
example. Nix supplies Tailwind and daisyUI; Make compiles CSS. Do not add a Node
project or runtime CDN.

Use the standard Modus Operandi theme. Interface typography pairs Concourse OT
with original TsangerYuYangT W02/W03; code uses Triplicate A Code. Use Concourse
Book (400, upright and italic), Medium (500), Semibold (600) and Bold (700), and
Triplicate regular/bold with their italics. Read the nine original WOFF2 files
from an optional private `MB_TYPE_DIR` outside the source checkout. Without it,
local builds use YuYang and system monospace. Never put purchased fonts or
receipts in Git, Nix sources or font binary caches. Keep complete class names
discoverable by CSS source scanning; continuous dimensions use CSS variables.
Filtering, URL state and preview loading policy belong to Hoot. The shared
presentation bootstrap handles interface fonts on every page without requiring
Hoot for manual reading. Reveal content after font readiness; on failure or
timeout, keep system fonts for the remainder of that navigation. Never apply a
late font swap after revealing content. With JavaScript disabled, use readable
system fonts. Browser bindings expose only necessary host operations.

Default filters select Simplified Chinese, sans-serif and open-source licenses,
with all vendors and costs and embedding unchecked. Choices within a category
use OR; categories use AND. Empty selections match nothing. Reset restores
defaults. Select-all includes collapsed options and reflects partial selections.
URL state and browser navigation must restore the same choices.

Maintain Simplified Chinese language names and sample mappings in `etc/` with
source notes. Preserve regional naming and actual sample languages; alternatives
must be in the same language. Do not add per-package sample selectors or a Babel
runtime dependency. Use stable machine keys and Chinese labels, including
unknown values. Package language coverage is a union, but each face's sample
must be supported by that face. Never conceal missing samples with fallback
fonts or another language.

## Public output and caching

The manual lives at `manual/`. Compile it with Texinfo, then wrap the generated
body using shared header and footer procedures in
`module/presentation/layout.scm`. Derive the chapter sidebar from Texinfo's
internal links, not a second hand-maintained table of contents. Preserve its
chapter, vendor-section and package-subsection hierarchy. Manual reading and
navigation must work without Hoot or JavaScript. Enhance same-origin manual
links by replacing only the article and pager; preserve the shared shell, loaded
fonts and sidebar state. Keep fragment links, keyboard focus, browser history
and scroll restoration working. Superseded requests must not replace newer
content; failed enhancement follows the original link. Do not intercept
downloads, external links or modified clicks. Share shell dimensions, theme and
interface fonts with the preview; scope manual typography to its content. Keep
chapter navigation available on small screens and keyboard-accessible. Publish
HTML and the Info download, not generated intermediate metadata or source
includes.

Keep reference fields, definitions, lists and notices in semantic Texinfo so
they remain readable in Info. Style the generated HTML with the site's theme;
Texinfo's `menu` and `table` classes are not daisyUI components and need scoped
layout rules. Preserve notice levels and links to their original sources.

Manual and preview source revisions must match. Include the manual and shared
layout in publication fingerprints, but not font-image fingerprints. Rebuilding
prose must reuse rendered previews. Validate manual output before replacing the
complete site. Keep the archive allowlist explicit for manual files.

Publish static HTML, CSS, public JSON, matching Hoot/Wasm assets, SVG
identifiers and transparent lossless WebP images. Catalog fonts are fixed images
only; never publish original font files, private manifests, local paths or
caches. The font-file exceptions are the original interface W02/W03 TTFs with
their license statement and, when privately supplied, the nine selected MB Type
WOFF2 files. Include a third-party license notice; these fonts are not CC0. Keep
the publication allowlist exact and verify originals when creating archives.
Redistribution metadata does not permit restoring live text previews.

Render in memory with Pango/Cairo and encode directly with libwebp: lossless,
quality 75, method 6 and exact transparent pixels. Convert premultiplied Cairo
ARGB correctly. Cache WebP only; validate decoded pixels, transparency and
nonblank content. Include encoding settings in cache identities. Preserve faces,
collection members, weights and named variable instances without converting or
subsetting font files. Scale images to the requested preview size and allow
horizontal scrolling instead of shrinking to fit.

Source links for packages, website code and licensing use the same full commit
ID. Cache identities include font contents, faces/instances, sample text and
relevant inspection/rendering settings. Reuse valid caches, bound concurrency
and propagate worker failures. Validate all staged output before replacing the
public directory; failures preserve the previous complete output. Clean only
artifacts owned by the operation.

Keep discovery, validation, rendering and publication separate. Validate process
exit status and structured output. Pass argument arrays, not shell-interpolated
filenames. Protocol stdout is machine-readable; diagnostics use stderr.
Distinguish JSON false, null, empty objects and arrays in both Guile and Hoot.

## Archives and publication

`make release` archives existing public output without rebuilding. Require an
explicit revision matching the catalog and a new release directory. Verify the
interface fonts and license against declared inputs. Allow only regular public
files, enforce the Pages size limit and produce a SHA-256 manifest. Validate
both manifest and archive before making extracted output available to deploy.

Hercules `buildSite` uses Make on the agent advertising
`chinese-fonts-overlay-site`. Its private `/site-state` mount holds rendering
caches and staged archives. Disable remote builders and post-build hooks, and
serialize build/upload with the mount lock. Only trusted main accesses the mount
and `site-artifact-upload` secret. Long builds use public GitHub reads rather
than expiring GitTokens.

Upload validated archives only to the private `chinese-fonts-overlay-site`
Garage bucket at `https://s3.bingshan.org`, region `garage`, using path-style
requests. Fleet owns endpoint, quota and encrypted keys. Hercules has bucket
read/write access without ownership; Actions has read-only access. Never reuse
unrelated credentials or upload font closures.

Store immutable archives under the source revision and write `manifest.json`
last. Under the single-writer lock, keep at most two complete versions including
pending deployments: remove the oldest before the next upload, retaining the
newest complete version. Reuse matching objects on retry and reject differing
replacements. Clean abandoned objects and abort stale multipart uploads. The 2
GiB logical quota does not bound temporary physical usage during reclamation.

The `deploy` workflow accepts verified Hercules `ci/hercules/onPush/buildSite`
successes or manual retries for current main. Run trusted default-branch code;
validate repository, sender, event source, manifest and archive. Check current
main before download and immediately before deployment. Serialize deployments
and restrict the Pages environment to main. Only the deploy job receives Pages
and OIDC write permissions; S3 read credentials belong only to preparation.
Preparation failures preserve the published site. Keep font-cache publication
independent; website handoff uses no tags, Releases or deployment receipts.

## Verification

Use small CC0 fixtures in `test/fixtures/fonts/`; `make check` must not fetch
the collection. Cover observable behavior and distinct failure boundaries, not
private helpers, fixed schema numbers or incidental layouts. Merge overlapping
coverage and remove obsolete assertions. For rejection checks, keep other inputs
valid and assert the expected diagnostic. Native Scheme tests use SRFI-64 and
must exit unsuccessfully on failure.

After build changes, check clean/incremental and parallel builds, an independent
build directory, selection changes, failure preservation and actual HTTP
serving. Verify that serving does not build. Inspect UI changes in a browser.
Reuse existing complete outputs and caches when valid; rebuild the collection
only when needed. Report verification limits explicitly.
