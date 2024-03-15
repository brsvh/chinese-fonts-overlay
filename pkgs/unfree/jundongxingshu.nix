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
  fontName = "jundongxingshu";
  fontChineseName = "仓耳俊冬行书";
  allowCommercialUse = false;
}
