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
  fontName = "mengdaimiaowei";
  fontChineseName = "仓耳萌呆喵尾体";
  allowCommercialUse = false;
}
