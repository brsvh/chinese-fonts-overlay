{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "wandongxingshu";
  fontChineseName = "仓耳万东行书";
  allowCommercialUse = false;
}
