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
    hash = "sha256-IfU7b2VTZfuWjs+76kfS4lr40sUjFmzRELtPk0gE6NM=";
    url = "https://hyperos.mi.com/font-download/MiSans_Lao.zip";
  };

  meta = {
    description = "MiSans Lao font family";
    homepage = "https://hyperos.mi.com/font/zh/details/lao";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Lao static OpenType font family from
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

  pname = "misans-lao";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    fontRoot="$(find . -maxdepth 1 -type d -name '*MiSans Lao' -print -quit)"
    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      "$fontRoot"/OpenType/MiSansLao-Thin.otf \
      "$fontRoot"/OpenType/MiSansLao-ExtraLight.otf \
      "$fontRoot"/OpenType/MiSansLao-Light.otf \
      "$fontRoot"/OpenType/MiSansLao.otf \
      "$fontRoot"/OpenType/MiSansLao-Normal.otf \
      "$fontRoot"/OpenType/MiSansLao-Medium.otf \
      "$fontRoot"/OpenType/MiSansLao-Demibold.otf \
      "$fontRoot"/OpenType/MiSansLao-Semibold.otf \
      "$fontRoot"/OpenType/MiSansLao-Bold.otf \
      "$fontRoot"/OpenType/MiSansLao-Heavy.otf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "MiSans Lao";
      embedding = true;

      languages = [
        "lo"
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
