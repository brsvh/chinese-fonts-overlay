{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "caozhebinjunxiukaishu-bold";
  fontChineseName = "仓耳曹哲斌俊秀楷书加粗";
  allowCommercialUse = false;
}
