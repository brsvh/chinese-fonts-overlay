{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yuxiaoxiao";
  fontChineseName = "仓耳雨潇潇体";
  allowCommercialUse = false;
}
