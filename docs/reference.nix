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
    overlays = [ (import (root + "/default.nix")) ];
  };
  inherit (pkgs.lib)
    attrNames
    concatMap
    filter
    isAttrs
    map
    optional
    toList
    unique
    ;
  catalog =
    import (root + "/lib/font-catalog.nix")
      {
        inherit pkgs;
        projectRoot = /. + root;
      };
  memberEntry =
    package:
    let
      entries = filter (
        item: item.pname == package.pname
      ) catalog.packages;
    in
    if builtins.length entries != 1 then
      throw "Manual aggregate member must have one catalog entry: ${package.pname}"
    else
      builtins.head entries;
  aggregateEntry =
    attribute:
    let
      package = pkgs.${attribute};
      members = map memberEntry (
        package.fontMembers or [ ]
      );
      info = package.chinese-fonts-overlay-site or { };
    in
    {
      inherit attribute;
      composed = package ? fontMembers;
      description = package.meta.description or "";
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
      members = map (entry: entry.attribute) members;
      vendors =
        if package ? fontMembers then
          unique (map (entry: entry.vendor) members)
        else
          [ info.vendor ];
    };
in
catalog
// {
  aggregates = map aggregateEntry (
    filter (
      attribute:
      pkgs.${attribute}.isFontAggregate or false
    ) (attrNames flake.packages.${system})
  );
}
