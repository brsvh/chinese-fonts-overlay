{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "lianaibiji";
  fontChineseName = "仓耳恋爱笔记体";
  allowCommercialUse = false;
}
