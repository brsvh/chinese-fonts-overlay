{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "runhei-w01";
  fontChineseName = "仓耳润黑W01";
  allowCommercialUse = false;
}
