{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yunhei-w07";
  fontChineseName = "仓耳云黑-W07";
  allowCommercialUse = false;
}
