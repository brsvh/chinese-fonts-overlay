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
  fontName = "leizhenhanfeng";
  fontChineseName = "仓耳雷震汉风体";
  allowCommercialUse = false;
}
