{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "guli-w01";
  fontChineseName = "仓耳谷力W01";
  allowCommercialUse = false;
}
