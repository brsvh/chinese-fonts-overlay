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
      -L '${guile-json}/share/guile/site/3.0' \
      -e main -s '${./main.scm}' "$@"
  '';
}
