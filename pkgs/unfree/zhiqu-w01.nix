{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "zhiqu-w01";
  fontChineseName = "仓耳知曲体W01";
  allowCommercialUse = false;
}
