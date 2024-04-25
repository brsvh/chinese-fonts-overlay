{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xunmengshilitaohua";
  fontChineseName = "寻梦十里桃花体";
  allowCommercialUse = false;
}
