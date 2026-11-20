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

      name = "TsangerDMMT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳大漫漫体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-BJ/OQ1LGiClZPc0fV0YK6fgBILRdCQT6EJ1ylAuzfdI=";
  w02Src = fetchFont "02" "sha256-agdAeA7ByF/n1kjbpPO1OOddm9lCMYnDc4plX/6bGPk=";
  w03Src = fetchFont "03" "sha256-fNNGlpAQrN4qEgkAz75hGFnO6lKGOP6wuJjoVm+DkQQ=";
  w04Src = fetchFont "04" "sha256-F6n6pErUhYfbpazG9vNWrtbvP1DTI6ssr4FKR8PmQ/0=";
  w05Src = fetchFont "05" "sha256-G/QJZWDssIBFUuqG/1M8lSzhm6MnzvtfLzx0J+rnucI=";

  meta = {
    description = "Tsanger DMMT font family";

    homepage = [
      "https://tsanger.cn/product/21"
      "https://tsanger.cn/product/22"
      "https://tsanger.cn/product/23"
      "https://tsanger.cn/product/24"
      "https://tsanger.cn/product/25"
    ];

    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger DMMT font family.

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

  pname = "tsangertype-tsangerdmmt";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerDMMT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerDMMT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerDMMT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerDMMT-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerDMMT-W05.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳大漫漫体";

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
        "serif"
        "song"
      ];

      vendor = "tsangertype";
    };
  };
}
