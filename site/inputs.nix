let
  root = builtins.getEnv "FONT_SITE_SOURCE_ROOT";
  flake = builtins.getFlake (
    builtins.getEnv "FONT_SITE_SOURCE_FLAKE"
  );
  pkgs = import flake.inputs.nixpkgs {
    config = {
      allowUnfree = true;
    };

    overlays = [
      (import (root + "/default.nix"))
    ];
  };

  catalog = import (root + "/site/catalog.nix") {
    inherit pkgs;
    projectRoot = /. + root;
  };

  previews = import (root + "/site/previews.nix") {
    inherit catalog pkgs;
  };
in
pkgs.writeText "font-site-inputs.json" (
  builtins.toJSON {
    inherit catalog previews;
  }
)
