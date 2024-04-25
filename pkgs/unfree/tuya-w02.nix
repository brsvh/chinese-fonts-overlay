{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "tuya-w02";
  fontChineseName = "仓耳涂鸦体W02";
  allowCommercialUse = false;
}
