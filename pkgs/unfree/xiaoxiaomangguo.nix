{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xiaoxiaomangguo";
  fontChineseName = "仓耳小小芒果体";
  allowCommercialUse = false;
}
