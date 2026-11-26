let
  root = builtins.getEnv "FONT_MANUAL_SOURCE_ROOT";
  flake = builtins.getFlake (
    builtins.getEnv "FONT_MANUAL_SOURCE_FLAKE"
  );
  system = builtins.getEnv "FONT_MANUAL_SYSTEM";

  pkgs = import flake.inputs.nixpkgs {
    inherit system;

    config = {
      allowUnfree = true;
    };

    overlays = [
      (import (root + "/default.nix"))
    ];
  };

  inherit (pkgs.lib)
    attrNames
    concatMap
    filter
    getAttrFromPath
    groupBy
    head
    isAttrs
    length
    map
    optional
    pipe
    splitString
    toList
    unique
    ;

  catalog =
    import (root + "/packages/font-catalog.nix")
      {
        inherit pkgs;

        projectRoot = /. + root;
      };

  derivationKey =
    package:
    builtins.unsafeDiscardStringContext package.drvPath;

  entriesByDerivation = groupBy (
    entry:
    let
      package = getAttrFromPath (splitString "." entry.attribute) pkgs;
    in
    derivationKey package
  ) catalog.packages;

  memberEntry =
    package:
    let
      entries =
        entriesByDerivation.${derivationKey package}
        or [ ];
    in
    if length entries != 1 then
      throw "Manual aggregate member must have one catalog entry: ${package.pname}"
    else
      head entries;

  aggregateEntry =
    attribute:
    let
      package = pkgs.${attribute};
      members = map memberEntry (
        package.fontMembers or [ ]
      );
      info = package.chinese-fonts-overlay-pages or { };
    in
    {
      inherit attribute;

      composed = package ? fontMembers;
      description = package.meta.description or "";
      members = map (entry: entry.attribute) members;
      notices = info.notices or [ ];

      upstreamUrls = unique (
        toList (package.meta.homepage or [ ])
        ++ concatMap (
          license:
          optional (
            isAttrs license && license ? url
          ) license.url
        ) (toList (package.meta.license or [ ]))
      );

      vendors =
        if package ? fontMembers then
          unique (map (entry: entry.vendor) members)
        else
          [ info.vendor ];
    };
in
catalog
// {
  aggregates = pipe flake.packages.${system} [
    attrNames
    (filter (
      attribute:
      pkgs.${attribute}.isFontAggregate or false
    ))
    (map aggregateEntry)
  ];
}
