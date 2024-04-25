{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "feibai-w02";
  fontChineseName = "仓耳非白W02";
  allowCommercialUse = true;
}
