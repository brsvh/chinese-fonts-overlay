{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "qinghe-w03";
  fontChineseName = "仓耳青禾体W03";
  allowCommercialUse = false;
}
