{
  catalog,
  pkgs,
}:
let
  inherit (pkgs.lib)
    getAttrFromPath
    listToAttrs
    splitString
    ;
in
listToAttrs (
  map (
    entry:
    let
      package = getAttrFromPath (splitString "." entry.attribute) pkgs;
    in
    {
      name = entry.id;

      value = {
        # Font files are inputs to the local image renderer only.
        renderPath = toString package;
      };
    }
  ) catalog.packages
)
