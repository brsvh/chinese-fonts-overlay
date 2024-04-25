{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "fengwujiutian-w03";
  fontChineseName = "仓耳锋舞九天W03";
  allowCommercialUse = false;
}
