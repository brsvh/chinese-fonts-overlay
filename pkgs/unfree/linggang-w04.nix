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
  fontName = "linggang-w04";
  fontChineseName = "仓耳凌刚体W04";
  allowCommercialUse = false;
}
