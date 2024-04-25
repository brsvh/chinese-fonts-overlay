{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "linggang-w03";
  fontChineseName = "仓耳凌刚体W03";
  allowCommercialUse = false;
}
