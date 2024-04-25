{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "minghei-w05";
  fontChineseName = "仓耳明黑W05";
  allowCommercialUse = false;
}
