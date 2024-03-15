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
  fontName = "mengduoduo";
  fontChineseName = "仓耳萌朵朵体";
  allowCommercialUse = false;
}
