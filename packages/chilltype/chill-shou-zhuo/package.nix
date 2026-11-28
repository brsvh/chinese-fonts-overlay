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

  pname = "chill-shou-zhuo";
  version = "2.500";

  src = fetchurl {
    hash = "sha256-3jRoWubYYRnEchND9VNc8pWBN/k1q8kezI+Q0ix/M9Y=";
    url = "https://github.com/Warren2060/ChillShouZhuo/releases/download/v${version}/ChillZhuo_v${version}.zip";
  };

  meta = {
    description = "Chill ShouZhuo casual handwritten Chinese font";

    homepage = [
      "https://github.com/Warren2060/ChillShouZhuo"
    ];

    license = licenses.chilltype-shouzhuo-license;

    longDescription = ''
      Provides Chill ShouZhuo from ChillType, a casual handwritten Chinese
      OpenType font covering GB2312 and common characters.

      The upstream README states that the font is free for public and
      commercial use with attribution when shared, but no standalone formal
      license file is provided and the font metadata states All Rights
      Reserved; this package conservatively marks it non-redistributable.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    src
    version
    ;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/chilltype
    find . -type f -name '*.otf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉手拙体";

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
          level = "warning";

          text = ''
            上游 README 声明免费授权全社会使用（包括商用）且分享需标注作者为寒蝉字型，但仓库未提供独立正式授权协议文件且字体元数据标示保留所有权利；本包保守标记为不可再分发。
          '';

          url = "https://github.com/Warren2060/ChillShouZhuo/blob/763e4380fce1443ae5e5bc3ccfd124863c2dc39f/README.md";
        }
      ];

      styles = [
        "handwritten"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
