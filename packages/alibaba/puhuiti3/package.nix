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

  version = "3.01-unstable-2023-05-26";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-8l9zC2p2YbzVuXZNyY8F06wl7ncZd88Esx7V+6n0lqc=";
    url = "https://fonts.alibabadesign.com/AlibabaPuHuiTi-3.zip";
  };

  meta = {
    description = "Alibaba PuHuiTi 3.0 font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba PuHuiTi 3.0 font family.

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

  pname = "alibaba-puhuiti-3";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaPuHuiTi-3";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaPuHuiTi-3-35-Thin/AlibabaPuHuiTi-3-35-Thin.otf \
      AlibabaPuHuiTi-3-45-Light/AlibabaPuHuiTi-3-45-Light.otf \
      AlibabaPuHuiTi-3-55-Regular/AlibabaPuHuiTi-3-55-Regular.otf \
      AlibabaPuHuiTi-3-55-RegularL3/AlibabaPuHuiTi-3-55-RegularL3.otf \
      AlibabaPuHuiTi-3-65-Medium/AlibabaPuHuiTi-3-65-Medium.otf \
      AlibabaPuHuiTi-3-75-SemiBold/AlibabaPuHuiTi-3-75-SemiBold.otf \
      AlibabaPuHuiTi-3-85-Bold/AlibabaPuHuiTi-3-85-Bold.otf \
      AlibabaPuHuiTi-3-95-ExtraBold/AlibabaPuHuiTi-3-95-ExtraBold.otf \
      AlibabaPuHuiTi-3-105-Heavy/AlibabaPuHuiTi-3-105-Heavy.otf \
      AlibabaPuHuiTi-3-115-Black/AlibabaPuHuiTi-3-115-Black.otf

    runHook postInstall
  '';
}
