{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "siyaoxingkai";
  fontChineseName = "仓耳丝摇行楷";
  allowCommercialUse = false;
}
