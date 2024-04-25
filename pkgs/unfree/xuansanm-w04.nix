{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xuansanm-w04";
  fontChineseName = "仓耳玄三M-W04";
  allowCommercialUse = false;
}
