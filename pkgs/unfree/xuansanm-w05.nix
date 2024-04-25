{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xuansanm-w05";
  fontChineseName = "仓耳玄三M-W05";
  allowCommercialUse = false;
}
