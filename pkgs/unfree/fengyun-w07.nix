{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "fengyun-w07";
  fontChineseName = "仓耳锋韵W07";
  allowCommercialUse = false;
}
