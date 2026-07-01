---
name: create-font-package
description: >-
  Initial analysis and scaffolding workflow for adding new font packages to this
  repository from one or more upstream font URLs. Use when asked to inspect font
  files, upstream repository metadata, font family names, hashes, license terms,
  package split or merge decisions, package names, Nix package skeletons, or
  initial integration requirements before or while creating packages under a
  vendor package directory.
---

# Create Font Package

Use this skill to turn one or more font file URLs into a concrete initial
packaging plan or first package implementation for this repository.

For `.nix` edits, also use the `nix-coding` skill before changing files.

## Workflow

1. Identify the target vendor scope and package directory from the user request,
   URL host, upstream project name, and repository conventions. If the user only
   asks for analysis, do not create files.
2. Inspect nearby package examples in the same vendor scope and similar font
   packages elsewhere in `packages/`.
3. Fetch upstream metadata for every URL:
   - release tag, asset names, sizes, and release notes;
   - repository description, homepage, README, license file, and fixed license
     URL when relevant;
   - source layout when release assets duplicate files in the repository.
4. Download each font file to `/tmp` and verify it:
   - `file`;
   - `nix hash file`;
   - upstream digest when available;
   - `fc-scan --brief`;
   - `fc-scan --format` for `family`, `fullname`, `postscriptname`, `style`,
     `fontversion`, `fontformat`, `foundry`, `color`, `outline`, `scalable`, and
     `charset` when coverage matters.
5. Decide package shape from font metadata:
   - one package when fonts share the same upstream project, release, license,
     and base family name, and differ only by style/subfamily;
   - separate packages when fonts have independent upstream products, licensing,
     versioning, family names, or expected installation choices;
   - use the upstream English family/product name for directory and attribute
     names unless existing local conventions require another stable name.
6. Decide license handling:
   - use an existing `lib.licenses` entry only when it accurately names and
     models the upstream terms;
   - for restricted custom font licenses, add a specific license entry in
     `lib/licenses.nix`;
   - do not use a generic label such as "upstream font license" as the full name
     for restricted fonts. Use a precise full name that identifies the licensor
     or product and the license text;
   - set `redistributable = false` unless the license clearly permits
     redistribution of the font files.
7. Draft the package:
   - use `fetchurl` for direct font assets;
   - use one `*Src` binding per asset when a package installs multiple files;
   - set `dontUnpack = true` for direct `.otf`, `.ttf`, `.otc`, or `.ttc`
     sources;
   - install OpenType fonts under `$out/share/fonts/opentype/<vendor>/`;
   - install TrueType fonts under `$out/share/fonts/truetype/<vendor>/`;
   - write `meta.longDescription` by following the section below.
8. Wire the package only when implementation is requested:
   - if the vendor scope already exists, adding
     `packages/<vendor>/<name>/package.nix` is usually enough for
     `packagesFromDirectoryRecursive`;
   - if the vendor scope is new, add overlay scope, aggregate package, flake
     exposure, and README/vendor notes as requested;
   - do not update preview-image tooling or README unless the user asks for it.
9. Validate narrowly:
   - `nix fmt`;
   - build the new package through the overlay, using an impure expression when
     the new file is not yet tracked by Git;
   - evaluate `meta.license.shortName` and any important package attributes;
   - inspect the built font files with `fc-scan`.

## Output

When the user asks for analysis, report:

- recommended package path, attribute name, and `pname`;
- whether multiple URLs should be one package or multiple packages, with the
  font family/style evidence;
- version, homepage, license, redistributability, hashes, install paths, and
  package skeleton details;
- any wiring or validation still needed.

When the user asks to implement, make the scoped code changes, run validation,
and summarize changed files and checks.

## Long Description

Write `meta.longDescription` as concise package metadata, not upstream marketing
copy.

- Use plain ASCII only. Prefer upstream English names and romanized licensor
  names in `longDescription`; keep non-ASCII official names in
  `license.fullName`, README entries, or comments only when needed.
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
