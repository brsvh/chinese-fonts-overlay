{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "daimengxiaomutou";
  fontChineseName = "仓耳呆萌小木头体";
  allowCommercialUse = false;
}
