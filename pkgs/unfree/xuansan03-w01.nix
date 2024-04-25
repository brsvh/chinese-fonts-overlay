{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xuansan03-w01";
  fontChineseName = "仓耳玄三03-W01";
  allowCommercialUse = false;
}
