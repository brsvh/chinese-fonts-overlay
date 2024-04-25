{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "mizhiguo";
  fontChineseName = "仓耳秘之果";
  allowCommercialUse = false;
}
