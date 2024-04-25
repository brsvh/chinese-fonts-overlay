{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "guodongxixi";
  fontChineseName = "仓耳果冻吸吸体";
  allowCommercialUse = false;
}
