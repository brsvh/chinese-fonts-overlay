{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "qingchunyiniweiming";
  fontChineseName = "仓耳青春以你为名体";
  allowCommercialUse = false;
}
