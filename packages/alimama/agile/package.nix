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

  version = "1.000-beta-unstable-2026-01-12";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-TTpuPA6VjaYjRg8o4CK/I800AclvWaCNfvNBI2N6IR8=";
    url = "https://fonts.alibabadesign.com/AlimamaAgileVF.zip";
  };

  meta = {
    description = "Alimama Agile VF font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alimama-agile-license;

    longDescription = ''
      Provides the Alimama Agile VF font family.

      The Alimama Agile Legal Statement governs use. The official
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

  pname = "alimama-agile";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/alimama \
      AlimamaAgileVF-Thin.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "阿里妈妈灵动体";
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
        "sans"
        "serif"
      ];

      vendor = "alimama";
    };
  };
}
