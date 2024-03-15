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
  fontName = "xiaowoniudemeng";
  fontChineseName = "仓耳小蜗牛的梦";
  allowCommercialUse = false;
}
