{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "zhouxinyoulong";
  fontChineseName = "仓耳周鑫游龙体";
  allowCommercialUse = false;
}
