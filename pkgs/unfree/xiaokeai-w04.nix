{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "xiaokeai-w04";
  fontChineseName = "仓耳小可爱体W04";
  allowCommercialUse = false;
}
