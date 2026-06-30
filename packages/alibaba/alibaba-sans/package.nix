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

  version = "1.02-unstable-2022-08-10";

  regularSrc = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-n0KnzpRKASq1aT+aEM9XB+Q/XHDy7+gbujyconuLCMU=";
    url = "https://fonts.alibabadesign.com/AlibabaSans.zip";
  };

  italicsSrc = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-pte/4Xt+BDJO2qCHL1E0MyVcjo5bjuzi/XjBUlHqGss=";
    url = "https://fonts.alibabadesign.com/AlibabaSansItalics.zip";
  };

  meta = {
    description = "Alibaba Sans font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans font family.

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
    version
    ;

  pname = "alibaba-sans";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  srcs = [
    regularSrc
    italicsSrc
  ];

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSans/AlibabaSans-Light/AlibabaSans-Light.otf \
      AlibabaSans/AlibabaSans-Regular/AlibabaSans-Regular.otf \
      AlibabaSans/AlibabaSans-Medium/AlibabaSans-Medium.otf \
      AlibabaSans/AlibabaSans-Bold/AlibabaSans-Bold.otf \
      AlibabaSans/AlibabaSans-Heavy/AlibabaSans-Heavy.otf \
      AlibabaSans/AlibabaSans-Black/AlibabaSans-Black.otf \
      AlibabaSansItalics/AlibabaSans-LightItalic/AlibabaSans-LightItalic.otf \
      AlibabaSansItalics/AlibabaSans-Italic/AlibabaSans-Italic.otf \
      AlibabaSansItalics/AlibabaSans-MediumItalic/AlibabaSans-MediumItalic.otf \
      AlibabaSansItalics/AlibabaSans-BoldItalic/AlibabaSans-BoldItalic.otf \
      AlibabaSansItalics/AlibabaSans-HeavyItalic/AlibabaSans-HeavyItalic.otf

    runHook postInstall
  '';
}
