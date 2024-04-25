{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "cangermuxi";
  fontChineseName = "仓耳木兮体";
  allowCommercialUse = false;
}
