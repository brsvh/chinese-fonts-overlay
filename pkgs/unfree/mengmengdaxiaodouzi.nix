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
  fontName = "mengmengdaxiaodouzi";
  fontChineseName = "萌萌哒小豆子体";
  allowCommercialUse = false;
}
