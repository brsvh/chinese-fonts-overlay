{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "feifei-w02";
  fontChineseName = "仓耳飞飞体W02";
  allowCommercialUse = false;
}
