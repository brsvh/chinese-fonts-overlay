{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xuansanm-w03";
  fontChineseName = "仓耳玄三M-W03";
  allowCommercialUse = false;
}
