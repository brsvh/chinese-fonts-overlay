let
  inherit (pkgs.lib)
    concatStringsSep
    elem
    filter
    getAttrFromPath
    listToAttrs
    nameValuePair
    splitString
    unique
    ;

  root = builtins.getEnv "FONT_PAGES_SOURCE_ROOT";
  flake = builtins.getFlake (
    builtins.getEnv "FONT_PAGES_SOURCE_FLAKE"
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
      builtins.getEnv "FONT_PAGES_PACKAGES"
    )
  );

  fullCatalog =
    import (root + "/packages/font-catalog.nix")
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
      throw "Unknown font package attributes: ${concatStringsSep ", " unknown}"
    else
      fullCatalog
      // {
        packages = filter (
          entry:
          selection == [ ] || elem entry.attribute selection
        ) fullCatalog.packages;
      };

  fontInput =
    entry:
    let
      package = getAttrFromPath (splitString "." entry.attribute) pkgs;
    in
    nameValuePair entry.id {
      # Font files are inputs to the local image renderer only.
      renderPath = toString package;
    };

  fontInputs = listToAttrs (
    map fontInput catalog.packages
  );
in
pkgs.writeText "font-site-inputs.json" (
  builtins.toJSON {
    inherit catalog fontInputs;
  }
)
