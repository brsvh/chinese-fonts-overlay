{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yunhei-w01";
  fontChineseName = "仓耳云黑-W01";
  allowCommercialUse = false;
}
