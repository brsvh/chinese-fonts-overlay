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

  src = fetchurl {
    hash = "sha256-Dce98hSzqS4ezL5/wdqxlFZ4/HdfISDnaOzjM8U3K7I=";
    name = "TsangerMDDT.ttf";
    url = "https://tsanger.cn/download/仓耳萌朵朵体.ttf";
  };

  meta = {
    description = "TsangerMDDT font";
    homepage = "https://tsanger.cn/product/130";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerMDDT font.

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
    src
    version
    ;

  pname = "tsangertype-tsangermddt";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerMDDT.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳萌朵朵体";

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
