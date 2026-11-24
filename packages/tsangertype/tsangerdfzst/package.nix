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

  regularSrc = fetchurl {
    hash = "sha256-zt7DPf26ca0SK+o8wjq2oUnbRE1Yk7mAk3QKmvkt5X4=";
    name = "TsangerDFZST-W01.ttf";
    url = "https://tsanger.cn/download/刀锋战士体.ttf";
  };

  boldSrc = fetchurl {
    hash = "sha256-lEmmEAsdgSVTsynkaBifSkP5t5zge9ZHnIDroQQuMfo=";
    name = "TsangerDFZSCT-W01.ttf";
    url = "https://tsanger.cn/download/刀锋战士粗体.ttf";
  };

  meta = {
    description = "Tsanger DFZST font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger DFZST font family.

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

  pname = "tsangertype-tsangerdfzst";

  dontUnpack = true;

  srcs = [
    regularSrc
    boldSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${regularSrc} $fontDir/TsangerDFZST-W01.ttf
    install -Dm444 ${boldSrc} $fontDir/TsangerDFZSCT-W01.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "刀锋战士体";

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
