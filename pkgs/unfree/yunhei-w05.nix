{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yunhei-w05";
  fontChineseName = "仓耳云黑-W05";
  allowCommercialUse = false;
}
