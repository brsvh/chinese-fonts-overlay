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
  fontName = "zhiqu-w05";
  fontChineseName = "仓耳知曲体W05";
  allowCommercialUse = false;
}
