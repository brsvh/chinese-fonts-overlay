{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yucheng-w05";
  fontChineseName = "仓耳羽辰体W05";
  allowCommercialUse = false;
}
