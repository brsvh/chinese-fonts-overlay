# Website Maintenance Guidelines

Read the [root guidelines](../AGENTS.md) as well. This file covers website work,
including related configuration outside `site/`. Paths below are relative to
this directory unless stated otherwise. User instructions belong in
[README](README).

## Boundaries

One handwritten `Makefile` owns the build. Nix supplies pinned tools, interface
assets and font inputs; there is no separate website or server package. `make`
builds, `make check` tests licensed fixtures, `make serve` serves existing
output, and `make release` archives it. Do not introduce a second build system.

Keep dependency ordering in Make and transformations in Guile. `scripts/` and
`module/chinese-fonts-overlay-site/` handle generation, rendering orchestration,
serving and platform-independent archive validation. `src/` contains native font
tools; `web/` contains Hoot interactions and styles; `data/` contains language
names and samples. Module loading must not start services or builds.

CI scheduling, credentials, remote state and publication belong to JavaScript
modules in `../ci/`. Package definitions and language maintenance belong outside
`site/`; website builds and tests must never rewrite packages.

## Inputs and builds

Read package metadata through `catalog.nix` and the shared
[validator](../lib/font-info.nix). Do not create a second package index. Exclude
`isFontAggregate` packages, preserve notices and sources, and resolve embedding
once in the public catalog. Missing license freedom is unknown.

By default, build the complete catalog into `BUILD_DIR/public`. `PACKAGES`
selects complete overlay attributes for local previews. Validate every selector
before realizing fonts, reject unknown or aggregate attributes, deduplicate the
selection and include it in input fingerprints. Realize only selected font
inputs; changing or clearing the selection must invalidate prepared inputs.
Reject `PACKAGES` with explicit `CATALOG` and `PREVIEWS`.

Separate native compilation, browser assets, input preparation, rendering and
publication. Refresh inputs when definitions, locks, catalog rules or package
membership change. Do not freeze data when entering a shell. Explicit `CATALOG`
and `PREVIEWS` must be supplied together and support builds without Nix.

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

Use the standard Modus Operandi theme and original TsangerYuYangT W02/W03
interface fonts. Keep complete class names discoverable by CSS source scanning;
continuous dimensions use CSS variables. Filtering, URL state and loading policy
belong to Hoot. Browser bindings expose only necessary host operations.

Default filters select Simplified Chinese, sans-serif and open-source licenses,
with all vendors and costs and embedding unchecked. Choices within a category
use OR; categories use AND. Empty selections match nothing. Reset restores
defaults. Select-all includes collapsed options and reflects partial selections.
URL state and browser navigation must restore the same choices.

Maintain Simplified Chinese language names and sample mappings in `data/` with
source notes. Preserve regional naming and actual sample languages; alternatives
must be in the same language. Do not add per-package sample selectors or a Babel
runtime dependency. Use stable machine keys and Chinese labels, including
unknown values. Package language coverage is a union, but each face's sample
must be supported by that face. Never conceal missing samples with fallback
fonts or another language.

## Public output and caching

Publish static HTML, CSS, public JSON, matching Hoot/Wasm assets, SVG
identifiers and transparent lossless WebP images. Catalog fonts are fixed images
only; never publish original font files, private manifests, local paths or
caches. The only font-file exception is the original interface W02/W03 TTFs,
accompanied by their license statement. Redistribution metadata does not permit
restoring live text previews.

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

Use small CC0 fixtures in `tests/fixtures/fonts/`; `make check` must not fetch
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
