{ callPackage
, lib
, ...
}:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation
{
  fontName = "xunzhaomoxianshouxie";
  fontChineseName = "寻找魔仙手写体";
  allowCommercialUse = false;
}
