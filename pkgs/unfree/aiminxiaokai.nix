{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "aiminxiaokai";
  fontChineseName = "仓耳爱民小楷";
  allowCommercialUse = false;
}
