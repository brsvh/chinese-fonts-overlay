{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xuansan01-w02";
  fontChineseName = "仓耳玄三01-W02";
  allowCommercialUse = false;
}
