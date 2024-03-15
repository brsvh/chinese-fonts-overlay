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
  fontName = "jiaotangmaqiduo";
  fontChineseName = "仓耳焦糖玛奇朵体";
  allowCommercialUse = false;
}
