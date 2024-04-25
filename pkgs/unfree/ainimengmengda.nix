{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "ainimengmengda";
  fontChineseName = "仓耳爱你萌萌哒";
  allowCommercialUse = false;
}
