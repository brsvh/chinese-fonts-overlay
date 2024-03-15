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
  fontName = "linggang-w01";
  fontChineseName = "仓耳凌刚体W01";
  allowCommercialUse = false;
}
