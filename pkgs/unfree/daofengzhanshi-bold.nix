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
  fontName = "daofengzhanshi-bold";
  fontChineseName = "刀锋战士粗体";
  allowCommercialUse = false;
}
