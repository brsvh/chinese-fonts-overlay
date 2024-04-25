{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "maobohe";
  fontChineseName = "仓耳猫薄荷体";
  allowCommercialUse = false;
}
