{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xiaomanman-w03";
  fontChineseName = "仓耳小漫漫体W03";
  allowCommercialUse = false;
}
