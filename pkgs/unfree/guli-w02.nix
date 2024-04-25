{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "guli-w02";
  fontChineseName = "仓耳谷力W02";
  allowCommercialUse = false;
}
