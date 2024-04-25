{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "mengmiaojiang";
  fontChineseName = "仓耳萌喵酱";
  allowCommercialUse = false;
}
