{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "bailing-w05";
  fontChineseName = "仓耳百灵W05";
  allowCommercialUse = false;
}
