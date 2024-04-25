{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xiuzhen";
  fontChineseName = "仓耳秀蓁体";
  allowCommercialUse = false;
}
