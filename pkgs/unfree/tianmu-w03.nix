{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "tianmu-w03";
  fontChineseName = "仓耳天沐体W03";
  allowCommercialUse = false;
}
