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
  fontName = "linggang-w05";
  fontChineseName = "仓耳凌刚体W05";
  allowCommercialUse = false;
}
