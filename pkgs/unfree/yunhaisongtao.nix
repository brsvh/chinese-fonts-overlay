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
  fontName = "yunhaisongtao";
  fontChineseName = "仓耳云海松涛体";
  allowCommercialUse = false;
}
