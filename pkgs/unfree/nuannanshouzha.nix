{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "nuannanshouzha";
  fontChineseName = "仓耳暖男手札体";
  allowCommercialUse = false;
}
