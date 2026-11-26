{
  flakeUrl ? root,
  mode ? "runtime",
  pkgs ? null,
  root ? null,
  selection ? [ ],
  system ? "x86_64-linux",
}:
let
  projectRoot = /. + root;
  flake = builtins.getFlake flakeUrl;

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
    pipe
    readDir
    ;

  discard = builtins.unsafeDiscardStringContext;

  vendors = pipe (projectRoot + /packages) [
    readDir
    (filterAttrs (_: kind: kind == "directory"))
    attrNames
  ];

  sourceInfo = source: {
    drvPath =
      if isDerivation source then
        discard source.drvPath
      else
        null;

    path = discard (toString source);
  };

  packageEntry =
    vendor: name: package:
    nameValuePair "${vendor}.${name}" {
      inherit vendor;

      inherit (package) pname;

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

      redistributable =
        (package.meta.redistributable or false) == true;

      sources = map sourceInfo (
        optional (package ? src) package.src
        ++ (package.srcs or [ ])
      );

      version = package.version or "";
      windows = vendor == "microsoft";
    };

  vendorEntries =
    vendor:
    pipe fontPkgs."${vendor}Packages" [
      (filterAttrs (_: isDerivation))
      (mapAttrsToList (packageEntry vendor))
    ];

  inventory = {
    packages = listToAttrs (
      concatMap vendorEntries vendors
    );

    schema = 1;
    system = fontPkgs.stdenv.hostPlatform.system;
  };
in
if mode == "inventory" then
  inventory
else if mode == "languages" then
  let
    catalog =
      import (projectRoot + /packages/font-catalog.nix)
        {
          inherit projectRoot;

          pkgs = fontPkgs;
        };
  in
  {
    packages = listToAttrs (
      map (
        entry:
        let
          package = inventory.packages.${entry.id};
        in
        nameValuePair entry.attribute {
          inherit (entry) languages;

          inherit (package) drvPath windows;
        }
      ) catalog.packages
    );

    scanner =
      discard
        flake.apps.${system}.update-font-languages.program;
  }
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
else if mode == "runtime" then
  pkgs.writeShellApplication {
    name = "chinese-fonts-overlay-ci";

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
