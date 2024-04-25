{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "qiaole-w05";
  fontChineseName = "仓耳巧乐体W05";
  allowCommercialUse = false;
}
