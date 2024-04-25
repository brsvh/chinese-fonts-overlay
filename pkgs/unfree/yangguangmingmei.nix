{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yangguangmingmei";
  fontChineseName = "仓耳阳光明媚体";
  allowCommercialUse = false;
}
