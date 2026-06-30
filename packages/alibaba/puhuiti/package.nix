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

  version = "1.30-unstable-2022-08-02";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-5vmtdoycNG1jmCqQWSaM0HiO9Su2PVDzHw3Cva5tEAI=";
    url = "https://fonts.alibabadesign.com/AlibabaPuHuiTi.zip";
  };

  meta = {
    description = "Alibaba PuHuiTi font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba PuHuiTi font family.

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

  pname = "alibaba-puhuiti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaPuHuiTi";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      Alibaba-PuHuiTi-Light/Alibaba-PuHuiTi-Light.otf \
      Alibaba-PuHuiTi-Regular/Alibaba-PuHuiTi-Regular.otf \
      Alibaba-PuHuiTi-Medium/Alibaba-PuHuiTi-Medium.otf \
      Alibaba-PuHuiTi-Bold/Alibaba-PuHuiTi-Bold.otf \
      Alibaba-PuHuiTi-Heavy/Alibaba-PuHuiTi-Heavy.otf

    runHook postInstall
  '';
}
