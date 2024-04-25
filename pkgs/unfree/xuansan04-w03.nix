{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xuansan04-w03";
  fontChineseName = "仓耳玄三04-W03";
  allowCommercialUse = false;
}
