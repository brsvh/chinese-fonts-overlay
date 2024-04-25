{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "jinkai04-w02";
  fontChineseName = "仓耳今楷04-W02";
  allowCommercialUse = false;
}
