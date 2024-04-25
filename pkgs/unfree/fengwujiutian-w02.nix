{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "fengwujiutian-w02";
  fontChineseName = "仓耳锋舞九天W02";
  allowCommercialUse = false;
}
