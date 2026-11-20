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

      name = "TsangerRunHei-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳润黑W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-S5vPt2i01AMryuQW9B95OCNK06kqPVrgnUltqSHUf/E=";
  w02Src = fetchFont "02" "sha256-dbwN0UBxrMtIwQhS8UpxHk2lGhumb+M2tpp4OlQJ0WI=";
  w03Src = fetchFont "03" "sha256-dh2WRLxoNqYMCdZslQCtp8w6um1gveBDsHvopCU3dLA=";

  meta = {
    description = "Tsanger Runhei font family";

    homepage = [
      "https://tsanger.cn/product/103"
      "https://tsanger.cn/product/104"
      "https://tsanger.cn/product/105"
    ];

    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Runhei font family.

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

  pname = "tsangertype-tsangerrunhei";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerRunHei-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerRunHei-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerRunHei-W03.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳润黑";

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
        "hei"
        "sans"
      ];

      vendor = "tsangertype";
    };
  };
}
