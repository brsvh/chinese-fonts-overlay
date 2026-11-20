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

  version = "0.001-unstable-2024-05-24";

  src = fetchurl {
    hash = "sha256-M7l1uHJOSte/zD+0fs959uu28MhtNvDHBSM3JvGW/HQ=";
    name = "TsangerMingYueTi-Regular.ttf";
    url = "https://tsanger.cn/download/仓耳明月体.ttf";
  };

  meta = {
    description = "TsangerMingYueTi-Regular font";
    homepage = "https://tsanger.cn/product/380";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerMingYueTi-Regular font.

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

  pname = "tsangertype-tsangermingyueti";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerMingYueTi-Regular.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳明月体";

      languages = [
        "agr"
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
        "kai"
        "sans"
      ];

      vendor = "tsangertype";
    };
  };
}
