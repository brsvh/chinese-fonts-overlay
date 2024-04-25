{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "feibai-w04";
  fontChineseName = "仓耳非白W04";
  allowCommercialUse = true;
}
