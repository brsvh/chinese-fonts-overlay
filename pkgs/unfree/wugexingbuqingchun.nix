{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "wugexingbuqingchun";
  fontChineseName = "仓耳无个性不青春体";
  allowCommercialUse = false;
}
