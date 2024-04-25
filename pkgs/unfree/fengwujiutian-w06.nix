{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "fengwujiutian-w06";
  fontChineseName = "仓耳锋舞九天W06";
  allowCommercialUse = false;
}
