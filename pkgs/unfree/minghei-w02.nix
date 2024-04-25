{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "minghei-w02";
  fontChineseName = "仓耳明黑W02";
  allowCommercialUse = false;
}
