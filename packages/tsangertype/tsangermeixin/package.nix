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

      name = "TsangerMeiXin-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳美心体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-YgEKqhpRtt6+jOQHyLwwlKhC4bFRLfbu4IVkrh8aTsQ=";
  w02Src = fetchFont "02" "sha256-lzTurAtK4F++hAwXsjbPPf8Rikm4nyw8c9nWAvYPUqY=";

  meta = {
    description = "Tsanger Meixin font family";

    homepage = [
      "https://tsanger.cn/product/123"
      "https://tsanger.cn/product/124"
    ];

    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Meixin font family.

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

  pname = "tsangertype-tsangermeixin";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerMeiXin-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerMeiXin-W02.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳美心体";

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
