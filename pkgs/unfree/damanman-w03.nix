{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "damanman-w03";
  fontChineseName = "仓耳大漫漫体W03";
  allowCommercialUse = false;
}
