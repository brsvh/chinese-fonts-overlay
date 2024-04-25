{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "bailing-w01";
  fontChineseName = "仓耳百灵W01";
  allowCommercialUse = false;
}
