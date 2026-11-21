{
  coreutils,
  fontconfig,
  guile,
  guile-json,
  lib,
  nix,
  writeShellApplication,
}:
let
  inherit (lib) getExe;
in
writeShellApplication {
  name = "chinese-fonts-overlay-update-font-languages";

  runtimeInputs = [
    coreutils
    fontconfig
    nix
  ];

  meta = {
    mainProgram = "chinese-fonts-overlay-update-font-languages";
  };

  text = ''
    exec ${getExe guile} --no-auto-compile \
      -L '${./module}' \
      -L '${guile-json}/share/guile/site/3.0' \
      -c '(use-modules (chinese-fonts-overlay-update-font-languages command))
          (exit (main (cdr (command-line))))' "$@"
  '';
}
