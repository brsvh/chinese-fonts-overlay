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
    git
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
  export PATH=${makeBinPath (packages ++ [ git ])}
  exec ${treefmt}/bin/treefmt \
    --config-file=${file} \
    --tree-root-file=flake.nix \
    --walk=git \
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
