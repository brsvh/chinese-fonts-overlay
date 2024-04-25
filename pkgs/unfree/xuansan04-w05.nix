{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xuansan04-w05";
  fontChineseName = "仓耳玄三04-W05";
  allowCommercialUse = false;
}
