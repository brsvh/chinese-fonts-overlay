{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "1.000-unstable-2024-05-24";

  fetchFont =
    weight: hash:
    fetchurl {
      inherit
        hash
        ;

      name = "TsangerChuangYi-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳创意体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-MvUOHUY3BUjX1+ppzUGGv540SBDum7CKEq3ba9jVcSY=";
  w02Src = fetchFont "02" "sha256-+qoSUFYwwCFWPZrY/sG3oZAZ96N232mpmPBFbhCF3CI=";
  w03Src = fetchFont "03" "sha256-E5MuZ7xAiDKdRnTMbmTw8SyG1WTL3SeTbxrvjUA2cpU=";

  meta = {
    description = "Tsanger ChuangYi font family";

    homepage = [
      "https://tsanger.cn/product/56"
      "https://tsanger.cn/product/57"
      "https://tsanger.cn/product/58"
    ];

    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger ChuangYi font family.

      TsangerType states that these fonts are free for personal,
      non-commercial use. Do not use them commercially, redistribute
      the font files, or publish them through a binary cache unless
      TsangerType permits it.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    version
    ;

  pname = "tsangertype-tsangerchuangyi";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerChuangYi-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerChuangYi-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerChuangYi-W03.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "仓耳创意体";

      languages = [
        "agr"
        "bem"
        "bg"
        "fj"
        "ho"
        "ia"
        "io"
        "kj"
        "kum"
        "kwm"
        "mhr"
        "ms"
        "ng"
        "nr"
        "om"
        "os"
        "rn"
        "ru"
        "rw"
        "sel"
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

      licenseCost = "gratisPersonalUse";

      notices = [
        {
          level = "warning";

          text = ''
            北京仓耳文字技术有限公司版权所有的商业付费字体不建议嵌入式使用，尽管其明确对个人非商业用途进行豁免，但用于个人网站仍然存在风险。
          '';
        }
      ];

      styles = [
        "art"
      ];

      vendor = "tsangertype";
    };
  };
}
