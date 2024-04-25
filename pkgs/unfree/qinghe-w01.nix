{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "qinghe-w01";
  fontChineseName = "仓耳青禾体W01";
  allowCommercialUse = false;
}
