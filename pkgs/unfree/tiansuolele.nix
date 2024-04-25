{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "tiansuolele";
  fontChineseName = "仓耳天锁乐乐体";
  allowCommercialUse = false;
}
