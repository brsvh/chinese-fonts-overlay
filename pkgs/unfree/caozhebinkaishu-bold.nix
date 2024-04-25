{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "caozhebinkaishu-bold";
  fontChineseName = "仓耳曹哲斌楷书加粗";
  allowCommercialUse = false;
}
