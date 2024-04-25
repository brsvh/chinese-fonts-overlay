{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "minghei-w01";
  fontChineseName = "仓耳明黑W01";
  allowCommercialUse = false;
}
