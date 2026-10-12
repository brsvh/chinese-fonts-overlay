{
  mode ? "runtime",
  pkgs ? null,
  root ? null,
  selection ? [ ],
  system ? "x86_64-linux",
}:
let
  previewRequests = { };

  projectRoot = /. + root;
  flake = builtins.getFlake root;

  fontPkgs =
    if pkgs != null then
      pkgs
    else
      import flake.inputs.nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };

        overlays = [
          flake.overlays.default
        ];
      };

  inherit (fontPkgs.lib)
    attrByPath
    attrNames
    concatMap
    filterAttrs
    isDerivation
    listToAttrs
    mapAttrsToList
    nameValuePair
    optional
    ;

  discard = builtins.unsafeDiscardStringContext;

  vendors = attrNames (
    filterAttrs (_: kind: kind == "directory") (
      builtins.readDir (projectRoot + /packages)
    )
  );

  sourceInfo = source: {
    drvPath =
      if isDerivation source then
        discard source.drvPath
      else
        null;

    path = discard (toString source);
  };

  entries = concatMap (
    vendor:
    mapAttrsToList
      (
        name: package:
        nameValuePair "${vendor}.${name}" {
          inherit vendor;

          attrPath = [
            "${vendor}Packages"
            name
          ];

          drvPath = discard package.drvPath;

          outputs = listToAttrs (
            map (
              output:
              nameValuePair output (
                discard (toString package.${output})
              )
            ) package.outputs
          );

          pname = package.pname;
          redistributable =
            (package.meta.redistributable or false) == true;

          sources = map sourceInfo (
            optional (package ? src) package.src
            ++ (package.srcs or [ ])
          );

          version = package.version or "";
          windows = vendor == "microsoft";
        }
      )
      (
        filterAttrs (
          _: isDerivation
        ) fontPkgs."${vendor}Packages"
      )
  ) vendors;

  inventory = {
    packages = listToAttrs entries;
    schema = 1;
    system = fontPkgs.stdenv.hostPlatform.system;
  };

  renderer = fontPkgs.callPackage (
    projectRoot
    + /tools/generate-font-preview-images/package.nix
  ) { };

in
if mode == "requests" then
  previewRequests
else if mode == "preview-requests" then
  let
    declaration = projectRoot + /ci/default.nix;
  in
  if builtins.pathExists declaration then
    import declaration {
      mode = "requests";
    }
  else
    { }
else if mode == "inventory" then
  inventory
else if mode == "outputs" then
  concatMap (
    name:
    let
      package =
        attrByPath inventory.packages.${name}.attrPath
          (throw "Unknown font package ${name}")
          fontPkgs;
    in
    map (output: package.${output}) package.outputs
  ) selection
else if mode == "renderer" then
  renderer
else if mode == "preview-config" then
  {
    rendererDrvPath = discard renderer.drvPath;

    requests = import ./default.nix {
      inherit root;
      mode = "preview-requests";
    };

    samples = import (
      projectRoot
      + /tools/generate-font-preview-images/sample-keys.nix
    );
  }
else if mode == "runtime" then
  pkgs.writeShellApplication {
    name = "font-ci";

    runtimeInputs = with pkgs; [
      git
      nix
      nodejs
    ];

    text = ''
      exec node ${./.}/cli.mjs "$@"
    '';
  }
else
  throw "Unknown CI mode ${mode}"
