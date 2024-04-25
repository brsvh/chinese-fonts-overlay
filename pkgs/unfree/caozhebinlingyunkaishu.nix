{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "caozhebinlingyunkaishu";
  fontChineseName = "仓耳曹哲斌灵韵楷书";
  allowCommercialUse = false;
}
