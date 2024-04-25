{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "haloutuxiansheng";
  fontChineseName = "仓耳哈喽兔先生体";
  allowCommercialUse = false;
}
