{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "babilong";
  fontChineseName = "仓耳吧吡咙体";
  allowCommercialUse = false;
}
