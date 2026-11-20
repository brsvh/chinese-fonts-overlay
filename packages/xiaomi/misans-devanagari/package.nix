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

      The MiSans Font Intellectual Property License Agreement permits
      distributing applications using unmodified MiSans fonts. Indicate
      their use in the software and retain the copyright notice and
      agreement. Standalone font redistribution and binary caches are not
      permitted.
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
    chinese-fonts-overlay-site = {
      displayName = "MiSans Devanagari";
      embedding = true;

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

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "warning";

          text = ''
            MiSans 允许随应用嵌入使用；须在软件中特别注明使用了 MiSans，并在字体副本中保留版权声明和许可协议。不得改编或二次开发字体，也不得单独分发、出售字体或将字体包上传到二进制缓存。
          '';

          url = "https://hyperos.mi.com/font-download/MiSans字体知识产权许可协议.pdf";
        }
      ];

      styles = [
        "sans"
      ];

      vendor = "xiaomi";
    };
  };
}
