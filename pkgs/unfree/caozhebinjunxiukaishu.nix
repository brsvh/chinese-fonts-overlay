{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "caozhebinjunxiukaishu";
  fontChineseName = "仓耳曹哲斌俊秀楷书";
  allowCommercialUse = false;
}
