{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "jinkai03-w02";
  fontChineseName = "仓耳今楷03-W02";
  allowCommercialUse = false;
}
