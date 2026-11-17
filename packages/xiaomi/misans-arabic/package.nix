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

  version = "1.002-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-8sxJOdIC1sZFxcsGEz+998qkINQyUGgvnTeSiEyLcuU=";
    url = "https://hyperos.mi.com/font-download/MiSans_Arabic.zip";
  };

  meta = {
    description = "MiSans Arabic font family";
    homepage = "https://hyperos.mi.com/font/zh/details/arabic";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Arabic static OpenType font family from
      Xiaomi.

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

  pname = "misans-arabic";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Arabic/MiSans Arabic";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      otf/MiSansArabic-Thin.otf \
      otf/MiSansArabic-ExtraLight.otf \
      otf/MiSansArabic-Light.otf \
      otf/MiSansArabic-Regular.otf \
      otf/MiSansArabic-Normal.otf \
      otf/MiSansArabic-Medium.otf \
      otf/MiSansArabic-Demibold.otf \
      otf/MiSansArabic-Semibold.otf \
      otf/MiSansArabic-Bold.otf \
      otf/MiSansArabic-Heavy.otf

    runHook postInstall
  '';

  passthru = {
    fontInfo = {
      languages = [
        "ar"
        "az-ir"
        "bem"
        "fa"
        "fj"
        "ho"
        "ia"
        "io"
        "kj"
        "kwm"
        "lah"
        "ms"
        "ng"
        "nr"
        "om"
        "ota"
        "pa-pk"
        "ps-af"
        "ps-pk"
        "rn"
        "rw"
        "sn"
        "ss"
        "st"
        "sw"
        "ts"
        "ug"
        "ur"
        "uz"
        "xh"
        "za"
        "zu"
      ];

      licenseCost = "commercialFree";

      notices = [
        {
          level = "warning";

          text = ''
            MiSans 系列字体允许嵌入式使用，但在使用时需要额外标明。
          '';

          url = "https://hyperos.mi.com/font-download/MiSans%E5%AD%97%E4%BD%93%E7%9F%A5%E8%AF%86%E4%BA%A7%E6%9D%83%E8%AE%B8%E5%8F%AF%E5%8D%8F%E8%AE%AE.pdf";
        }
      ];

      styles = [
        "sans"
      ];

      vendor = "xiaomi";
    };
  };
}
