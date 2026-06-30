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

  version = "1.006-beta-unstable-2026-01-12";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-u5YPD0ZKQsFO0hX04bS94LLmm6/oW+PnHKGr9UxKtVM=";
    url = "https://fonts.alibabadesign.com/AlimamaDongFangDaKai.zip";
  };

  meta = {
    description = "Alimama DongFangDaKai font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alimama-dongfangdakai-license;

    longDescription = ''
      Provides the Alimama DongFangDaKai font family.

      Accept the Alimama DongFangDaKai Legal Statement before use.
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

  pname = "alimama-dongfangdakai";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alimama \
      AlimamaDongFangDaKai-Regular.otf

    runHook postInstall
  '';
}
