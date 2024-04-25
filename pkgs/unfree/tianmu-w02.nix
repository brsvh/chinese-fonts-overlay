{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "tianmu-w02";
  fontChineseName = "仓耳天沐体W02";
  allowCommercialUse = false;
}
