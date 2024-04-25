{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "zhiyuxiwenqing";
  fontChineseName = "仓耳治愈系文青";
  allowCommercialUse = false;
}
