{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xingfuyuezhang";
  fontChineseName = "仓耳幸福乐章体";
  allowCommercialUse = false;
}
