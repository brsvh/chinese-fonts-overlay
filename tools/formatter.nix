{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    makeBinPath
    ;

  inherit (pkgs)
    treefmt
    writeShellScriptBin
    ;

  inherit
    (config.devShells.default.passthru.files.treefmt)
    data
    file
    packages
    ;
in
(writeShellScriptBin "treefmt" ''
  set -euo pipefail
  export PATH=${makeBinPath packages}
  exec ${treefmt}/bin/treefmt \
    --config-file=${file} \
    --tree-root-file=flake.nix \
    "$@"
'').overrideAttrs
  (_: {
    passthru = {
      inherit
        data
        file
        packages
        ;
    };
  })
