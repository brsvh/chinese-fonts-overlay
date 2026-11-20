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

      name = "TsangerFFT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳飞飞体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-BbaLD1wZENdegBp6epLkudL1KDRUdC9D4dIROUIdAHw=";
  w02Src = fetchFont "02" "sha256-F00qtZSQkykZAV568q2a5HY/q5Njto91G9tRQVsdDHo=";
  w03Src = fetchFont "03" "sha256-1w53ipJ2SQr8lKr3IBPnauAJXwwqOVufy4VMNEB8sRQ=";
  w04Src = fetchFont "04" "sha256-0NmF7RV0IRQOjiZY6WB2OJDNoTEcCF1Q8q6NNsHLz7o=";

  meta = {
    description = "Tsanger FFT font family";

    homepage = [
      "https://tsanger.cn/product/162"
      "https://tsanger.cn/product/163"
      "https://tsanger.cn/product/164"
      "https://tsanger.cn/product/165"
    ];

    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger FFT font family.

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

  pname = "tsangertype-tsangerfft";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerFFT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerFFT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerFFT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerFFT-W04.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳飞飞体";

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
        "handwritten"
      ];

      vendor = "tsangertype";
    };
  };
}
