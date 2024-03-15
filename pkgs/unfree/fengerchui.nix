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
  fontName = "fengerchui";
  fontChineseName = "仓耳风儿吹";
  allowCommercialUse = false;
}
