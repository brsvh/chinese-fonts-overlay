{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "qinghe-w02";
  fontChineseName = "仓耳青禾体W02";
  allowCommercialUse = false;
}
