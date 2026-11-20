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
    hash = "sha256-55ZcJWVlAocwdz54DlgT3BhThQURPOAPmROEfnGpR1w=";
    url = "https://hyperos.mi.com/font-download/MiSans_Gujarati.zip";
  };

  meta = {
    description = "MiSans Gujarati VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/gujarati";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Gujarati VF variable TrueType font
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

  pname = "misans-gujarati-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Gujarati";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      MiSans\ Gujarati\ VF.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "MiSans Gujarati VF";
      embedding = true;

      languages = [
        "gu"
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
