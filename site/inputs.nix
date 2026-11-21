let
  inherit (pkgs.lib) elem filter unique;

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

  selection = unique (
    builtins.fromJSON (
      builtins.getEnv "FONT_SITE_PACKAGES"
    )
  );

  fullCatalog =
    import (root + "/site/catalog.nix")
      {
        inherit pkgs;
        projectRoot = /. + root;
      };

  attributes = map (
    entry: entry.attribute
  ) fullCatalog.packages;
  unknown = filter (
    attribute: !(elem attribute attributes)
  ) selection;
  catalog =
    if unknown != [ ] then
      throw "Unknown font package attributes: ${builtins.concatStringsSep ", " unknown}"
    else
      fullCatalog
      // {
        packages = filter (
          entry:
          selection == [ ] || elem entry.attribute selection
        ) fullCatalog.packages;
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
