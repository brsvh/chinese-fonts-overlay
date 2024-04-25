{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xiuxianxingshu";
  fontChineseName = "仓耳绣线行书";
  allowCommercialUse = false;
}
