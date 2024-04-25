{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "damanman-w05";
  fontChineseName = "仓耳大漫漫体W05";
  allowCommercialUse = false;
}
