---
name: create-font-preview
description: >-
  Workflow for creating or repairing font preview PNGs for this repository from
  a given package pname. Use when asked to clone or use the font-preview-images
  branch, choose or fix preview sample keys, run generate-font-preview-images
  for selected packages, validate generated preview images, or iterate on blank,
  vertical, or malformed font previews.
---

# Create Font Preview

Use this skill when the user gives one package `pname` and wants preview images
created, repaired, or checked for this repository.

If editing `.nix` files, also use the `nix-coding` skill before changing them.

## Workflow

1. Confirm the target `pname`.
   - Treat the input as a package `pname`, not an attribute name.
   - If more than one `pname` is requested, process them one at a time unless
     the user explicitly asks for a batch operation.
2. Ensure the preview image worktree exists at repository root:
   - If `font-preview-images/.git` exists, verify it is on the
     `font-preview-images` branch and has the expected remote.
   - If it is missing, clone
     `https://github.com/brsvh/chinese-fonts-overlay.git` with
     `--branch font-preview-images --single-branch` into `font-preview-images`.
   - If `font-preview-images` exists but is not a Git worktree, stop and ask
     before moving or deleting anything.
3. Find the package and sample-key status.
   - Locate the package with `rg -n 'pname = "<pname>"' packages`.
   - Check `tools/generate-font-preview-images/package.nix` for an entry in
     `fontPreviewPackageSampleKeys`.
   - If a sample key is already configured, keep it unless there is direct
     evidence that it targets the wrong script or language.
   - If no sample key is configured, inspect the package fonts with
     `fc-scan --brief` and `fc-scan --format` on the built font files. Use
     family names, style names, language metadata, charset ranges, and upstream
     documentation to infer the best existing sample key.
4. Choose or fix the sample key.
   - Prefer the narrowest existing sample key that exercises the intended script
     or language.
   - Available keys are `english`, `devanagari`, `japanese`, `javanese`,
     `korean`, `math`, `mongolian`, `myanmar`, `phagspa`, `simplified-chinese`,
     `symbols`, `tai-le`, `tai-lue`, `southeast-asian`, `thai`, `tibetan`,
     `traditional-chinese`, `vietnamese`, and `yi`.
   - For Traditional Chinese fonts, prefer `traditional-chinese`; for Simplified
     Chinese fonts, prefer `simplified-chinese`; for Latin-only fonts, prefer
     `english`; for icon or symbol fonts, prefer `symbols`.
   - Keep sample text consistent across packages. Do not add a package-specific
     sample key only because a shorter sample looks better, wraps less, or
     avoids renderer trouble. Fix rendering and layout instead.
   - Add a new sample key only when it represents a reusable script or language
     category missing from the generator; ask before adding one-off or
     package-specific sample text.
   - If the sample key must be added or changed, edit
     `tools/generate-font-preview-images/package.nix` and run `nix fmt` on it.
5. Generate previews incrementally through the generator devShell:
   - Use
     `nix develop .#generator -c generate-font-preview-images --package-name <pname>`.
   - Do not use `--override` for the first run unless the user asks to replace
     existing previews.
   - Record the image paths printed by the command and inspect
     `git -C font-preview-images status --short`.
6. Validate generated or changed PNGs.
   - Check every new or changed PNG for the target `pname`.
   - Use `magick identify -format '%k %wx%h\n' <image>` or equivalent. A
     one-color image is blank and invalid.
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
   - After changing the sample key or generator, run `nix fmt` and regenerate
     with
     `nix develop .#generator -c generate-font-preview-images --override --package-name <pname>`.
   - Repeat until the preview is nonblank and horizontal, or report the blocker
     with the inspected font metadata and renderer behavior.

## Output

Report the selected `pname`, chosen sample key, generated or changed image
paths, validation result, and any `.nix` edits made. Do not commit or push image
repository changes unless the user asks for that explicitly.
