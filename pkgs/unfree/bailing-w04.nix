{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "bailing-w04";
  fontChineseName = "仓耳百灵W04";
  allowCommercialUse = false;
}
