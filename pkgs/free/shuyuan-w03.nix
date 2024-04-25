{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "shuyuan-w03";
  fontChineseName = "仓耳舒圆体W03";
  allowCommercialUse = true;
}
