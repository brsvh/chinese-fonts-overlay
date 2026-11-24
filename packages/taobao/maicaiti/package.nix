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

  version = "1.000-unstable-2024-09-25";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-tf15bD1+6vDBOKbmeEMJ6/GOYPiNPOAYV0NZ0KmgHc0=";
    url = "https://fonts.alibabadesign.com/TaoBaoMaiCaiTi.zip";
  };

  meta = {
    description = "Taobao MaiCaiTi font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.taobao-maicaiti-license;

    longDescription = ''
      Provides the Taobao MaiCaiTi font family.

      The Taobao MaiCaiTi Legal Statement and official FAQ permit app
      embedding without charging users for use of the font. Credit Taobao
      where possible; do not convert, modify, or sublicense the font for a
      fee without permission. This overlay does not permit standalone font
      redistribution or publication through a binary cache.
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

  pname = "taobao-maicaiti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "TaoBaoMaiCaiTi-Regular";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/taobao \
      TaoBaoMaiCaiTi-Regular.otf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "淘宝买菜体";
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
        "zh-sg"
        "zu"
      ];

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "important";

          text = ''
            官方 FAQ 允许嵌入应用，但不得因使用字体向用户或会员收费。应标注版权所有人（无法标注时除外）；不得擅自转换、拆分、修改字体或有偿转授权，也不得将字体作为标志字用于商标注册。
          '';

          url = "https://note.youdao.com/s/Wg8v4gWC";
        }
      ];

      styles = [
        "art"
        "hei"
        "sans"
      ];

      vendor = "taobao";
    };
  };
}
