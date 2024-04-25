{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "fengyun-w06";
  fontChineseName = "仓耳锋韵W06";
  allowCommercialUse = false;
}
