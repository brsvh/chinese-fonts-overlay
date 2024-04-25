{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "gufengkaishu";
  fontChineseName = "仓耳古风楷书";
  allowCommercialUse = false;
}
