{
  fetchurl,
  lib,
  stdenv,
  ...
}:
{
  fontName,
  fontChineseName,
  allowCommercialUse ? false,
}:
with builtins;
with lib;
let
  inherit (stdenv) mkDerivation;

  freeCommercialLicense = {
    shortName = "tsangertype-free-license";
    fullName = "仓耳字库免费商用字体授权";
    url = "https://www.tsanger.cn/仓耳字库免费商用字体授权声明.pdf";
    free = false;
    redistributable = true;
  };

  personalNonCommercialLicense = {
    shortName = "tsangertype-unfree-license";
    fullName = "仓耳字库个人非商用字体授权";
    url = "https://www.tsanger.cn/TODO";
    free = false;
    redistributable = true;
  };

  pname = "tsangertype-font-${fontName}";

  src = fetchurl {
    sha256 = (import ../shas.nix)."${fontChineseName}";
    url = "http://tsanger.cn/download/${fontChineseName}.ttf";
  };

  version = import ../version.nix;

  meta = {
    license = if allowCommercialUse then freeCommercialLicense else personalNonCommercialLicense;

    description = "${fontName} font distributed by tsangertype";

    longDescription = ''
      tsangertype ${fontName} font is a unfree font distributed by tsangertype.
    '';

    homepage = "https://tsanger.cn";
  };
in
mkDerivation {
  inherit
    meta
    pname
    src
    version
    ;

  unpackPhase = ''
    :
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsanger/${fontName}.ttf;

    runHook postInstall
  '';
}
