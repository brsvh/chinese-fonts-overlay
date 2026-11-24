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

  version = "1.003-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-hKubMSoKvoUFywCu3+BAterE164Zqf8+mkIvWKEyUO4=";
    url = "https://hyperos.mi.com/font-download/MiSans_Thai.zip";
  };

  meta = {
    description = "MiSans Thai font family";
    homepage = "https://hyperos.mi.com/font/zh/details/thai";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Thai static OpenType font family from
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

  pname = "misans-thai";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Thai";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      otf/MiSansThai-Thin.otf \
      otf/MiSansThai-ExtraLight.otf \
      otf/MiSansThai-Light.otf \
      otf/MiSansThai.otf \
      otf/MiSansThai-Normal.otf \
      otf/MiSansThai-Medium.otf \
      otf/MiSansThai-Demibold.otf \
      otf/MiSansThai-Semibold.otf \
      otf/MiSansThai-Bold.otf \
      otf/MiSansThai-Heavy.otf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "MiSans Thai";
      embedding = true;

      languages = [
        "th"
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
