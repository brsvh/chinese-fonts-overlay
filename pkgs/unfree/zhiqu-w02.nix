{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "zhiqu-w02";
  fontChineseName = "仓耳知曲体W02";
  allowCommercialUse = false;
}
