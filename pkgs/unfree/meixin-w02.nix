{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "meixin-w02";
  fontChineseName = "仓耳美心体W02";
  allowCommercialUse = false;
}
