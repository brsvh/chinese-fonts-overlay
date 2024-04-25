{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "meixin-w01";
  fontChineseName = "仓耳美心体W01";
  allowCommercialUse = false;
}
