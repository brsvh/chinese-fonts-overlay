{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "nihaoshiguang";
  fontChineseName = "仓耳你好时光体";
  allowCommercialUse = false;
}
