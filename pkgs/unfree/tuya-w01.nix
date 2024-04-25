{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "tuya-w01";
  fontChineseName = "仓耳涂鸦体W01";
  allowCommercialUse = false;
}
