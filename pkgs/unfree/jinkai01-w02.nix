{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "jinkai01-w02";
  fontChineseName = "仓耳今楷01-W02";
  allowCommercialUse = false;
}
