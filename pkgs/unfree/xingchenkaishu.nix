{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xingchenkaishu";
  fontChineseName = "仓耳星辰楷书";
  allowCommercialUse = false;
}
