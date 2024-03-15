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
  fontName = "linggang-w02";
  fontChineseName = "仓耳凌刚体W02";
  allowCommercialUse = false;
}
