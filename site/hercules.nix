{
  inputs,
  mode,
  rev,
  root,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;
in
effects.mkEffect {
  name = "font-site-${mode}";
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
      guile --no-auto-compile -L ${root}/site/module \
      ${root}/site/scripts/deploy.scm ${mode} ${rev}
  '';

  inputs = with pkgs; [
    curl
    git
    gnutar
    guile
    guile-gcrypt
    guile-json
    gzip
    nix
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
