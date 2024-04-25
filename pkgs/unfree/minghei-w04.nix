{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "minghei-w04";
  fontChineseName = "仓耳明黑W04";
  allowCommercialUse = false;
}
