{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "tongzhuo";
  fontChineseName = "仓耳同桌体";
  allowCommercialUse = false;
}
