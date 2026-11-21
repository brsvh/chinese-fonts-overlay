---
name: create-font-package
description: >-
  Initial analysis and scaffolding workflow for adding font packages to
  Chinese-fonts-overlay-compatible Nix repositories from one or more upstream
  font URLs. Use when asked to inspect font files, upstream repository
  metadata, font family names, hashes, license terms, package split or merge
  decisions, package names, Nix package skeletons, preview generation, catalog
  metadata, or initial integration requirements before or while creating
  packages under a vendor package directory.
---

# Create Font Package

Use this skill to turn one or more font file URLs into a concrete initial
packaging plan or first package implementation in a compatible Nix font overlay.

## Establish the target

Find the target checkout from the user's workspace, then read its applicable
`AGENTS.md` and development instructions. The installed skill directory is not
the target repository. Paths below are relative to that checkout, not the
current shell directory or the skill directory.

This workflow describes the Chinese-fonts-overlay layout: `packages/`,
`lib/licenses.nix`, a root `README`, contribution guidance under `.github/`, and
the generated preview website under `site/`. Confirm those paths, package
discovery, flake outputs, catalog inputs, and preview publication settings in
the actual checkout. Adapt renamed equivalents; do not introduce this layout
into an unrelated project. If the required integration cannot be identified,
report what is missing before editing it.

Discover tools through the target's declared development environment. Nix,
Fontconfig (`fc-scan`), `file`, and a downloader are needed for their respective
steps; do not assume they are globally installed. Resolve companion skills such
as `nix-coding` by name from the available skill catalog, not by a fixed sibling
path. Use them when available or required by the target's instructions;
otherwise follow the target's own documented equivalent workflow.

## Workflow

01. Identify the target vendor scope and package directory from the user
    request, URL host, upstream project name, and repository conventions. If the
    user only asks for analysis, do not create files.
02. Inspect nearby package examples in the same vendor scope and similar font
    packages elsewhere in `packages/`.
03. Fetch upstream metadata for every URL:
    - release tag, asset names, sizes, and release notes;
    - repository description, homepage, README, license file, and fixed license
      URL when relevant;
    - source layout when release assets duplicate files in the repository.
04. Allocate a unique task-owned temporary directory using the environment's
    temporary-directory facility. Download each font file there and verify it:
    - `file`;
    - `nix hash file`;
    - upstream digest when available;
    - `fc-scan --brief`;
    - `fc-scan --format` for `family`, `fullname`, `postscriptname`, `style`,
      `fontversion`, `fontformat`, `foundry`, `color`, `outline`, `scalable`,
      and `charset` when coverage matters.
05. Decide package shape from font metadata:
    - one package when fonts share the same upstream project, release, license,
      and base family name, and differ only by style/subfamily;
    - separate packages when fonts have independent upstream products,
      licensing, versioning, family names, or expected installation choices;
    - use the upstream English family/product name for directory and attribute
      names unless existing local conventions require another stable name.
06. Decide license handling:
    - use an existing `lib.licenses` entry only when it accurately names and
      models the upstream terms;
    - for restricted custom font licenses, add a specific license entry in
      `lib/licenses.nix`;
    - do not use a generic label such as "upstream font license" as the full
      name for restricted fonts. Use a precise full name that identifies the
      licensor or product and the license text;
    - set `redistributable = false` unless the license clearly permits
      redistribution of the font files.
07. Draft the package:
    - use `fetchurl` for direct font assets;
    - use one `*Src` binding per asset when a package installs multiple files;
    - set `dontUnpack = true` for direct `.otf`, `.ttf`, `.otc`, or `.ttc`
      sources;
    - install OpenType fonts under `$out/share/fonts/opentype/<vendor>/`;
    - install TrueType fonts under `$out/share/fonts/truetype/<vendor>/`;
    - write `meta.longDescription` by following the section below;
    - fill in catalog metadata using the target schema and documented workflow;
      derive language coverage from the installed fonts rather than guessing.
08. Wire the package only when implementation is requested:
    - if the vendor scope already exists, adding
      `packages/<vendor>/<name>/package.nix` is usually enough for
      `packagesFromDirectoryRecursive`;
    - if the vendor scope is new, add overlay scope, aggregate package, flake
      exposure, and catalog registration as required by the target;
    - if the user explicitly asks to avoid preview or README changes, obey that
      narrower request and report the skipped integration.
09. Validate narrowly:
    - run the target's configured Nix formatter on the changed files;
    - register new files with Git before using a Git-backed flake; an impure
      expression alone does not make untracked files visible to that flake;
    - build the package through the overlay and inspect installed fonts and
      required license files;
    - run the target's metadata check and language maintenance tool in check
      mode; build success does not validate passthru metadata or language lists;
    - use the tool's explicit write mode when updating coverage, then review the
      source diff. Keep private scan reports out of public artifacts.
10. Check the generated website after package builds succeed:
    - follow the target's website maintenance instructions, selecting only the
      affected package attributes when supported; for this layout, use
      `make -C site PACKAGES='<overlay attributes>'` in the website shell;
    - adjust default filters to the selected font's language, style and license;
    - inspect the package entry, licensing information, language coverage, and
      all included font styles in the generated previews;
    - use the website's language samples, without adding per-package sample keys
      or restoring historical branch-preview tooling;
    - clean up only task-owned temporary files.
11. Complete user-facing integration:
    - if the catalog is generated from package metadata, maintain that source of
      truth instead of adding a manual README gallery or a second package index;
    - update documentation only when installation, usage, or maintenance
      changes;
    - if the target still maintains a manual gallery, follow its documented
      layout and derive image links from existing generated files and verified
      publication settings; do not invent preview links or assume that a fork
      publishes to its upstream repository.

## Output

When the user asks for analysis, report:

- recommended package path, attribute name, and `pname`;
- whether multiple URLs should be one package or multiple packages, with the
  font family/style evidence;
- version, homepage, license, redistributability, hashes, install paths, and
  package skeleton details;
- any wiring or validation still needed.

When the user asks to implement, make the scoped changes, validate the package
and its catalog or preview integration, and summarize changed files and checks.
Update documentation when usage changes. Mention any required integration left
unfinished because of the user's scope or a blocker.

## Long Description

Write `meta.longDescription` as concise package metadata, not upstream marketing
copy.

- Use plain ASCII only. Prefer upstream English names and romanized licensor
  names in `longDescription`; keep non-ASCII official names in
  `license.fullName`, catalog notices, documentation, or comments when needed.
- Keep the whole text short: usually 40-90 words, and rarely more than 120 words
  for restricted licenses. Use one or two paragraphs, no Markdown lists, no
  URLs, no hashes, and no installation instructions.
- First paragraph: summarize what the package provides in one sentence. Name the
  upstream font or style names that users would choose between, but do not dump
  `fc-scan` evidence such as family names, full names, PostScript names, charset
  ranges, or detailed coverage. Put that evidence in the analysis report, not in
  `longDescription`.
- Mention script, language, ligature, emoji, or glyph coverage only when it is
  essential for identifying the package or choosing between included fonts.
  Prefer broad wording such as "Bopomofo and Latin display fonts" over long
  coverage lists.
- Second paragraph: include it only when the license has prerequisites, payment,
  redistribution limits, commercial-use limits, modification limits, warranty
  disclaimers that matter to package users, or other restrictions.
- For restricted or custom font licenses, do not write "the upstream font
  license" or another generic substitute. Name the license or the
  licensor/product in ASCII, for example "The Tain Bun Sia and justfont Snail
  Font license". Then state what permission is already granted or must be
  obtained, and the important restrictions after permission is obtained.
- For permissive licenses such as OFL, usually keep the license fact in
  `meta.license` and omit the second paragraph unless upstream-specific
  conditions would surprise users.
- Keep the wording factual and narrow. Do not claim broad CJK, Unicode, emoji,
  or language coverage unless the font metadata or upstream documentation
  supports it.
- Validate generated text with `LC_ALL=C rg -n '[^\x00-\x7F]' <package.nix>` and
  inspect the rendered Nix string if quoting or indentation changed.
- A good Snail Font shape is:

```
Provides Snail Font Pomacea and Snail Font Sinotaia, two Bopomofo and
Latin display font styles from justfont and Tain Bun Sia.
```
