{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "mingkai-w03";
  fontChineseName = "仓耳明楷W03";
  allowCommercialUse = false;
}
