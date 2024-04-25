{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "zaijiannaxienian";
  fontChineseName = "仓耳再见那些年体";
  allowCommercialUse = false;
}
