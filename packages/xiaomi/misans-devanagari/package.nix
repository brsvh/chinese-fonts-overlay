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

  version = "1.000-unstable-2023-10-18";

  src = fetchurl {
    hash = "sha256-zkBmNUlR3fI09aBRcHjgNOs9xacQ1y3n5H54FXMeePg=";
    url = "https://hyperos.mi.com/font-download/MiSans_Devanagari.zip";
  };

  meta = {
    description = "MiSans Devanagari font family";
    homepage = "https://hyperos.mi.com/font/zh/details/devanagari";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Devanagari static OpenType font family
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

  pname = "misans-devanagari";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Devanagari";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      OpenType/MiSansDevanagari-Thin.otf \
      OpenType/MiSansDevanagari-ExtraLight.otf \
      OpenType/MiSansDevanagari-Light.otf \
      OpenType/MiSansDevanagari.otf \
      OpenType/MiSansDevanagari-Normal.otf \
      OpenType/MiSansDevanagari-Medium.otf \
      OpenType/MiSansDevanagari-Demibold.otf \
      OpenType/MiSansDevanagari-Semibold.otf \
      OpenType/MiSansDevanagari-Bold.otf \
      OpenType/MiSansDevanagari-Heavy.otf

    runHook postInstall
  '';

  passthru = {
    fontInfo = {
      languages = [
        "anp"
        "bh"
        "bhb"
        "bho"
        "brx"
        "doi"
        "hi"
        "hif"
        "hne"
        "kok"
        "mag"
        "mai"
        "mr"
        "ne"
        "raj"
        "sa"
        "the"
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
