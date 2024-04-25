{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "aiqinglianxisheng";
  fontChineseName = "仓耳爱情练习生";
  allowCommercialUse = false;
}
