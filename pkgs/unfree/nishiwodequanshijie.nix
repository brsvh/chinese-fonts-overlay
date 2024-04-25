{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "nishiwodequanshijie";
  fontChineseName = "你是我的全世界";
  allowCommercialUse = false;
}
