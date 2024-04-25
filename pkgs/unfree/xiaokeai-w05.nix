{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xiaokeai-w05";
  fontChineseName = "仓耳小可爱体W05";
  allowCommercialUse = false;
}
