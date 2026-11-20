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

      name = "TsangerGuLi-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳谷力W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-ObrmqaEcup7F+XPugKmCPEAwl63BGI1cdphvQ1Ik2JU=";
  w02Src = fetchFont "02" "sha256-kIL9rIuenOKFby5gzhW5ZMTECMAXAgA3FT+v9WUJlS4=";
  w03Src = fetchFont "03" "sha256-surDYV/HPMWMkArIn9bBAgeEdWD0klRopWnNL7A0Gz0=";
  w04Src = fetchFont "04" "sha256-GKG3K76d4b8bLE9WgOQWcGTsr05NRZHdOn3kgesksos=";
  w05Src = fetchFont "05" "sha256-NihJbSnesZgG+p504fbJx9eMgfbAMxWDwj5xo6KXV2U=";

  meta = {
    description = "TsangerGuLi font family";

    homepage = [
      "https://tsanger.cn/product/131"
      "https://tsanger.cn/product/132"
      "https://tsanger.cn/product/133"
      "https://tsanger.cn/product/134"
      "https://tsanger.cn/product/135"
    ];

    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerGuLi font family.

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

  pname = "tsangertype-tsangerguli";

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
    install -Dm444 ${w01Src} $fontDir/TsangerGuLi-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerGuLi-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerGuLi-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerGuLi-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerGuLi-W05.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳谷力";

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
