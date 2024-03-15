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
  fontName = "tianmimi";
  fontChineseName = "仓耳甜蜜蜜体";
  allowCommercialUse = false;
}
