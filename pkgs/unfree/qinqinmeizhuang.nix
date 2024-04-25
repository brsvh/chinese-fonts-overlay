{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "qinqinmeizhuang";
  fontChineseName = "亲亲美妆体";
  allowCommercialUse = false;
}
