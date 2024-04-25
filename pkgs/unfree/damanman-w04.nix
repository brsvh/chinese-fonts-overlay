{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "damanman-w04";
  fontChineseName = "仓耳大漫漫体W04";
  allowCommercialUse = false;
}
