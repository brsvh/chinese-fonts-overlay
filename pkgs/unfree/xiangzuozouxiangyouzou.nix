{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xiangzuozouxiangyouzou";
  fontChineseName = "仓耳向左走向右走体";
  allowCommercialUse = false;
}
