{
  inputs,
  rev,
  root,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  inherit (pkgs.lib)
    toJSON
    ;

  effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;
in
effects.mkEffect {
  name = "chinese-fonts-overlay-ci-buildPages";
  dontUnpack = true;

  NIX_CONFIG = ''
    experimental-features = nix-command flakes ca-derivations
    accept-flake-config = false
    builders =
    post-build-hook =
  '';

  __hci_effect_mounts = toJSON {
    "/pages-state" = "chinese-fonts-overlay-pages";
  };

  effectScript = ''
    set -euo pipefail
    umask 077
    flock /pages-state/build.lock \
      node ${root}/ci/pages.mjs buildPages ${rev}
  '';

  inputs = with pkgs; [
    awscli2
    git
    gnutar
    guile
    guile-gcrypt
    guile-json
    gzip
    nix
    nodejs
    util-linux
  ];

  requiredSystemFeatures = [
    "chinese-fonts-overlay-pages"
  ];

  secretsMap = {
    pagesArtifacts = "pages-artifact-upload";
    webfonts = "webfont-input-read";
  };
}
