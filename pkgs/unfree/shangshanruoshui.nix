{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "shangshanruoshui";
  fontChineseName = "仓耳上善若水";
  allowCommercialUse = false;
}
