{
  inputs,
  action,
  rev,
  root,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;
in
effects.mkEffect {
  name = "chinese-fonts-overlay-ci-${action}";
  dontUnpack = true;

  NIX_CONFIG = ''
    experimental-features = nix-command flakes ca-derivations
    accept-flake-config = false
    builders =
    post-build-hook =
  '';

  __hci_effect_mounts = builtins.toJSON {
    "/site-state" = "chinese-fonts-overlay-site";
  };

  effectScript = ''
    set -euo pipefail
    umask 077
    flock /site-state/site.lock \
      node ${root}/ci/site.mjs ${action} ${rev}
  '';

  inputs = with pkgs; [
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
    "chinese-fonts-overlay-site"
  ];

  secretsMap = {
    git = {
      type = "GitToken";
    };
  };
}
