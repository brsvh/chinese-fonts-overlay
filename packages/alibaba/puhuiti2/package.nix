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

  version = "2.00-unstable-2022-08-02";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-mtN+B1bNU4Or3idX2mXIpNqTSiIVqGkmfsaIxuwoQ8U=";
    url = "https://fonts.alibabadesign.com/AlibabaPuHuiTi-2.zip";
  };

  meta = {
    description = "Alibaba PuHuiTi 2.0 font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba PuHuiTi 2.0 font family.

      Accept the Alibaba PuHuiTi 3.0 Legal Statement before use.
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

  pname = "alibaba-puhuiti-2";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaPuHuiTi-2";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaPuHuiTi-2-35-Thin/AlibabaPuHuiTi-2-35-Thin.otf \
      AlibabaPuHuiTi-2-45-Light/AlibabaPuHuiTi-2-45-Light.otf \
      AlibabaPuHuiTi-2-55-Regular/AlibabaPuHuiTi-2-55-Regular.otf \
      AlibabaPuHuiTi-2-65-Medium/AlibabaPuHuiTi-2-65-Medium.otf \
      AlibabaPuHuiTi-2-75-SemiBold/AlibabaPuHuiTi-2-75-SemiBold.otf \
      AlibabaPuHuiTi-2-85-Bold/AlibabaPuHuiTi-2-85-Bold.otf \
      AlibabaPuHuiTi-2-95-ExtraBold/AlibabaPuHuiTi-2-95-ExtraBold.otf \
      AlibabaPuHuiTi-2-105-Heavy/AlibabaPuHuiTi-2-105-Heavy.otf \
      AlibabaPuHuiTi-2-115-Black/AlibabaPuHuiTi-2-115-Black.otf

    runHook postInstall
  '';
}
