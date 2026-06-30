{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "1.004-beta-unstable-2026-01-12";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-5sMWmdswNpa22Zo4ZGsaBK9hb7dW9FxoYoPxL+cLoXY=";
    url = "https://fonts.alibabadesign.com/AlimamaFangYuanTiVF.zip";
  };

  meta = {
    description = "Alimama FangYuanTi VF font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alimama-fangyuanti-license;

    longDescription = ''
      Provides the Alimama FangYuanTi VF font family.

      Accept the Alimama FangYuanTi Legal Statement before use.
      After accepting it, do not redistribute the font files or
      publish them through a binary cache.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "alimama-fangyuanti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/alimama \
      AlimamaFangYuanTiVF-Thin.ttf

    runHook postInstall
  '';
}
