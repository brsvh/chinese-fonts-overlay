{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "zhangyuxiaowanzi";
  fontChineseName = "仓耳章鱼小丸子体";
  allowCommercialUse = false;
}
