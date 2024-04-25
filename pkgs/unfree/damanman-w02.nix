{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "damanman-w02";
  fontChineseName = "仓耳大漫漫体W02";
  allowCommercialUse = false;
}
