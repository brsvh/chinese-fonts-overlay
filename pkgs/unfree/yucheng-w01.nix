{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yucheng-w01";
  fontChineseName = "仓耳羽辰体W01";
  allowCommercialUse = false;
}
