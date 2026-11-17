---
name: create-font-preview
description: >-
  Workflow for creating or repairing font preview PNGs in a
  Chinese-fonts-overlay-compatible Nix repository from a package pname. Use
  when asked to clone or use the font-preview-images branch, choose or fix
  preview sample keys, run generate-font-preview-images for selected packages,
  validate generated preview images, or iterate on blank, vertical, or
  malformed font previews.
---

# Create Font Preview

Use this skill when the user gives one package `pname` and wants preview images
created, repaired, or checked in a compatible Nix font overlay.

## Establish the target

Locate the target checkout from the user's workspace and read its applicable
`AGENTS.md` and development instructions. The installed skill directory is not
the target checkout. Resolve the paths below against the target repository.

This workflow expects the Chinese-fonts-overlay package layout and preview
branch generator. Confirm the actual package paths, generator entry point,
sample definitions, and publication settings before using them. Adapt renamed
equivalents; do not create this architecture in an unrelated repository. These
are branch-preview conventions, not rules for an independent website's language
samples or image renderer.

Use the target's declared environment for Nix, Fontconfig, and image inspection;
do not assume globally installed tools or a previously populated local cache.
Use unique task-owned temporary directories when needed. Resolve `nix-coding` by
name from the available skill catalog for Nix edits, not a fixed sibling path;
if unavailable, follow the target's own style and formatter instructions.

## Workflow

1. Confirm the target `pname`.
   - Treat the input as a package `pname`, not an attribute name.
   - If more than one `pname` is requested, process them one at a time unless
     the user explicitly asks for a batch operation.
2. Locate or create the preview checkout:
   - Determine its path, source repository, and branch from the target's
     publication documentation, CI configuration, and Git remotes. Existing
     image URLs can corroborate these settings. The usual path and branch are
     `font-preview-images`. Do not assume a fork uses the original upstream's
     publication repository or that `origin` is always the right source.
   - If a checkout exists, verify its remote, branch, and worktree status.
     Preserve unrelated changes. `.git` may be either a file or a directory.
   - If missing, clone the verified repository and preview branch into the
     documented destination. Confirm the branch exists before cloning; report a
     missing branch or ambiguous publication target instead of inventing it.
   - If the destination exists but is not a Git worktree, stop and ask before
     moving or deleting anything.
3. Find the package and sample-key status.
   - Locate the package with `rg -n 'pname = "<pname>"' packages`.
   - Check `tools/generate-font-preview-images/sample-keys.nix` for the package
     `pname` in its vendor attribute set.
   - If a sample key is already configured, keep it unless there is direct
     evidence that it targets the wrong script or language.
   - If no sample key is configured, inspect the package fonts with
     `fc-scan --brief` and `fc-scan --format` on the built font files. Use
     family names, style names, language metadata, charset ranges, and upstream
     documentation to infer the best existing sample key.
4. Choose or fix the sample key.
   - Prefer the narrowest existing sample key that exercises the intended script
     or language.
   - Read the available keys and texts from the actual generator's sample
     definitions; do not treat this skill as a versioned key registry.
   - When supported by those definitions, prefer `traditional-chinese` for
     Traditional Chinese, `simplified-chinese` for Simplified Chinese, `english`
     for Latin-only fonts, and `symbols` for icon or symbol fonts.
   - Keep sample text consistent across packages. Do not add a package-specific
     sample key only because a shorter sample looks better, wraps less, or
     avoids renderer trouble. Fix rendering and layout instead.
   - Add a new sample key only when it represents a reusable script or language
     category missing from the generator; ask before adding one-off or
     package-specific sample text.
   - If the sample key must be added or changed, edit
     `tools/generate-font-preview-images/sample-keys.nix` and format the changed
     file with the target's configured formatter.
5. Generate previews incrementally through the declared environment:
   - Confirm the generator devShell and command options in the checkout. Where
     the documented `generator` output is available, use
     `nix develop .#generator -c generate-font-preview-images --package-name <pname>`.
   - Do not use `--override` for the first run unless the user asks to replace
     existing previews.
   - Record the image paths printed by the command and inspect
     `git -C font-preview-images status --short`.
6. Validate generated or changed PNGs.
   - Check every new or changed PNG for the target `pname`.
   - Use `magick identify -format '%k %wx%h\n' <image>` from the declared
     image-tool environment, or an available equivalent. A one-color image is
     blank and invalid.
   - Require previews to be horizontal. Width must be greater than height, and a
     visibly tall or wrapped preview is invalid even when it is nonblank.
   - Missing glyph boxes are acceptable when the preview is otherwise nonblank.
   - Use visual inspection when the image may be cropped, empty-looking, or
     rendered with an unexpected font.
7. Iterate only when validation fails.
   - If the image is blank, first determine whether the sample key is wrong or
     the renderer cannot draw the font. Color, CFF, SVG, bitmap, or unusual
     outline fonts may render blank with ImageMagick even when the font is
     usable.
   - When renderer support is the problem, prefer a generic generator fix such
     as a Pango/fontconfig fallback over changing the sample key. Keep the
     sample consistent with the configured key.
   - If the image is nonblank but vertical, wrapped, or too tall, keep the
     sample key and fix rendering layout instead, such as by using a wider
     internal canvas before trimming/resizing.
   - Change the sample key only when the preview clearly uses the wrong script
     or language for the font.
   - After changing the sample key or generator, format the changed authored
     files and regenerate with the verified entry point, for example
     `nix develop .#generator -c generate-font-preview-images --override --package-name <pname>`.
   - Repeat until the preview is nonblank and horizontal, or report the blocker
     with the inspected font metadata and renderer behavior.

## Output

Report the selected `pname`, chosen sample key, generated or changed image
paths, validation result, and any `.nix` edits made. Do not commit or push image
repository changes unless the user asks for that explicitly.
