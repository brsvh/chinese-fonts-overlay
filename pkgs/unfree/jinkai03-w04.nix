{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "jinkai03-w04";
  fontChineseName = "仓耳今楷03-W04";
  allowCommercialUse = false;
}
