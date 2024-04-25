{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yunhei-w04";
  fontChineseName = "仓耳云黑-W04";
  allowCommercialUse = false;
}
