{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yihei-w04";
  fontChineseName = "仓耳逸黑W04";
  allowCommercialUse = false;
}
