{ callPackage
, lib
, ...
}:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation
{
  fontName = "qinghe-w05";
  fontChineseName = "仓耳青禾体W05";
  allowCommercialUse = false;
}
