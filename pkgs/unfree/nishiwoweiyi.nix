{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "nishiwoweiyi";
  fontChineseName = "仓耳你是我唯一";
  allowCommercialUse = false;
}
