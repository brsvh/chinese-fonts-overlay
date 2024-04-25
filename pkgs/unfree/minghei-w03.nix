{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "minghei-w03";
  fontChineseName = "仓耳明黑W03";
  allowCommercialUse = false;
}
