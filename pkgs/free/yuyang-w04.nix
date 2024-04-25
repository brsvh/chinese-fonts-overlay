{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yuyang-w04";
  fontChineseName = "仓耳渔阳体W04";
  allowCommercialUse = true;
}
