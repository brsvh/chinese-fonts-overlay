{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yihei-w03";
  fontChineseName = "仓耳逸黑W03";
  allowCommercialUse = false;
}
