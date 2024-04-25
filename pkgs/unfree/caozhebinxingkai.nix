{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "caozhebinxingkai";
  fontChineseName = "仓耳曹哲斌行楷";
  allowCommercialUse = false;
}
