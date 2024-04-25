{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "caozhebinlingyunkaishu-bold";
  fontChineseName = "仓耳曹哲斌灵韵楷书加粗";
  allowCommercialUse = false;
}
