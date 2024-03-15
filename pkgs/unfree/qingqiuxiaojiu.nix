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
  fontName = "qingqiuxiaojiu";
  fontChineseName = "仓耳青丘小九";
  allowCommercialUse = false;
}
