{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "aiminxingshu";
  fontChineseName = "仓耳爱民行书";
  allowCommercialUse = false;
}
