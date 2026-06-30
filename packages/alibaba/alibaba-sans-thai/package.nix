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

  version = "1.00-unstable-2022-08-02";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-tBc1KF1mN2r1JO+1mc+vQhu6cwcu9iSgNQTqqpfVyoA=";
    url = "https://fonts.alibabadesign.com/AlibabaSansThai.zip";
  };

  meta = {
    description = "Alibaba Sans Thai font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans Thai font family.

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

  pname = "alibaba-sans-thai";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaSansThai";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSansThai-Rg/AlibabaSansThai-Rg.otf \
      AlibabaSansThai-Md/AlibabaSansThai-Md.otf \
      AlibabaSansThai-Bd/AlibabaSansThai-Bd.otf

    runHook postInstall
  '';
}
