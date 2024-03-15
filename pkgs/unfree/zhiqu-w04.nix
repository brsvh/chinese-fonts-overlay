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
  fontName = "zhiqu-w04";
  fontChineseName = "仓耳知曲体W04";
  allowCommercialUse = false;
}
