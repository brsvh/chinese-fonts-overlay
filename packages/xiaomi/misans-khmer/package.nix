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

  version = "1.200-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-69YBt39k8FTuEQf5+gAi9XKErm4sM0LJJIk7Mkz5bGA=";
    url = "https://hyperos.mi.com/font-download/MiSans_Khmer.zip";
  };

  meta = {
    description = "MiSans Khmer font family";
    homepage = "https://hyperos.mi.com/font/zh/details/khmer";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Khmer static OpenType font family from
      Xiaomi.

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

  pname = "misans-khmer";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Khmer";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      OTF/MiSansKhmer-Thin.otf \
      OTF/MiSansKhmer-ExtraLight.otf \
      OTF/MiSansKhmer-Light.otf \
      OTF/MiSansKhmer-Regular.otf \
      OTF/MiSansKhmer-Normal.otf \
      OTF/MiSansKhmer-Medium.otf \
      OTF/MiSansKhmer-Demibold.otf \
      OTF/MiSansKhmer-Semibold.otf \
      OTF/MiSansKhmer-Bold.otf \
      OTF/MiSansKhmer-Heavy.otf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "MiSans Khmer";
      embedding = true;

      languages = [
        "km"
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
