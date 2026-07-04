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

  version = "1.000-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-CH2NC5oR5Il/YGC1/YiWQkOpoBk+WHqSIk75oFcAY/w=";
    url = "https://hyperos.mi.com/font-download/MiSans_Myanmar.zip";
  };

  meta = {
    description = "MiSans Myanmar font family";
    homepage = "https://hyperos.mi.com/font/zh/details/myanmar";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Myanmar static OpenType font family
      from Xiaomi.

      The package uses the MiSans Font Intellectual Property
      License Agreement and is treated as non-redistributable in
      this overlay. Do not publish the built font files through a
      binary cache.
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

  pname = "misans-myanmar";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Myanmar";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      otf/MiSansMyanmar-Thin.otf \
      otf/MiSansMyanmar-ExtraLight.otf \
      otf/MiSansMyanmar-Light.otf \
      otf/MiSansMyanmar-Regular.otf \
      otf/MiSansMyanmar-Normal.otf \
      otf/MiSansMyanmar-Medium.otf \
      otf/MiSansMyanmar-Demibold.otf \
      otf/MiSansMyanmar-Semibold.otf \
      otf/MiSansMyanmar-Bold.otf \
      otf/MiSansMyanmar-Heavy.otf

    runHook postInstall
  '';
}
