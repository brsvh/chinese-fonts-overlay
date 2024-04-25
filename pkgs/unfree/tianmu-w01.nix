{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "tianmu-w01";
  fontChineseName = "仓耳天沐体W01";
  allowCommercialUse = false;
}
