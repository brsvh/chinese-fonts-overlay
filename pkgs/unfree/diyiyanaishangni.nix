{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "diyiyanaishangni";
  fontChineseName = "仓耳第一眼爱上你";
  allowCommercialUse = false;
}
