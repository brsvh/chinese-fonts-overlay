{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "fengwujiutian-w01";
  fontChineseName = "仓耳锋舞九天W01";
  allowCommercialUse = false;
}
