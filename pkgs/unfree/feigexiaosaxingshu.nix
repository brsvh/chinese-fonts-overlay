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
  fontName = "feigexiaosaxingshu";
  fontChineseName = "飞哥潇洒行书";
  allowCommercialUse = false;
}
