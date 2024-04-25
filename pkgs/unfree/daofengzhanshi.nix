{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "daofengzhanshi";
  fontChineseName = "刀锋战士体";
  allowCommercialUse = false;
}
