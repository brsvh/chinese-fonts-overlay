{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "dianshichengjin";
  fontChineseName = "仓耳点石成金体";
  allowCommercialUse = false;
}
