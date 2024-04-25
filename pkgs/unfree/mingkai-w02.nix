{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "mingkai-w02";
  fontChineseName = "仓耳明楷W02";
  allowCommercialUse = false;
}
