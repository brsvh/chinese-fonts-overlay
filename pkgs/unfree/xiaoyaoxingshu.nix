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
  fontName = "xiaoyaoxingshu";
  fontChineseName = "仓耳逍遥行书";
  allowCommercialUse = false;
}
