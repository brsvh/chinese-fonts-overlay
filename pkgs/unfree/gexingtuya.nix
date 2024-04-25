{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "gexingtuya";
  fontChineseName = "仓耳个性涂鸦体";
  allowCommercialUse = false;
}
