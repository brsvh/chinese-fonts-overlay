{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "gufengxingshu";
  fontChineseName = "仓耳古风行书";
  allowCommercialUse = false;
}
