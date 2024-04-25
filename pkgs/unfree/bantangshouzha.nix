{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "bantangshouzha";
  fontChineseName = "仓耳半糖手札";
  allowCommercialUse = false;
}
