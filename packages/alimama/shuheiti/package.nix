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

  version = "1.005-beta-unstable-2026-01-12";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-+7S38cpfO2BDKlbDKdqY5ZY4hYZBPczN3ZdxejtDzOQ=";
    url = "https://fonts.alibabadesign.com/AlimamaShuHeiTi.zip";
  };

  meta = {
    description = "Alimama ShuHeiTi font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alimama-shuheiti-license;

    longDescription = ''
      Provides the Alimama ShuHeiTi font family.

      The Alimama ShuHeiTi Legal Statement governs use. The official
      Alimama FAQ permits app embedding without charging for font use,
      but excludes trademark registration using the font as logo lettering.
      Modification and other restrictions in the statement still apply.
      Standalone font redistribution and binary caches remain disabled.
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

  pname = "alimama-shuheiti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alimama \
      AlimamaShuHeiTi-Bold.otf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "阿里妈妈数黑体";
      embedding = true;

      languages = [
        "bem"
        "fj"
        "ho"
        "ia"
        "io"
        "kj"
        "kwm"
        "ms"
        "ng"
        "nr"
        "om"
        "rn"
        "rw"
        "sn"
        "ss"
        "st"
        "sw"
        "ts"
        "uz"
        "xh"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "important";

          text = ''
            官方 FAQ 允许嵌入应用，但不得因字体使用向用户或会员收费，也不得将字体作为标志字用于商标注册或进行二次创作。各自法律声明中的署名、保留声明和转授权等限制仍适用。
          '';

          url = "https://www.yuque.com/alimama_ai-font/vfse9w/co47p8ge57qsanz2";
        }
      ];

      styles = [
        "hei"
        "sans"
      ];

      vendor = "alimama";
    };
  };
}
