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

  version = "1.000-unstable-2024-11-18";

  fangSrc = fetchurl {
    hash = "sha256-1+SFZwqwyEPKzWlUqvfFZ+x4Ut53pe4RvF25sGv900o=";
    name = "TsangerQingYa-Fang.ttf";
    url = "https://tsanger.cn/download/仓耳青雅-方.ttf";
  };

  yuanSrc = fetchurl {
    hash = "sha256-b6NTXqDArXyW6ofUaFomRxuSZuFoRNcul6K5zB6klYk=";
    name = "TsangerQingYa-Yuan.ttf";
    url = "https://tsanger.cn/download/仓耳青雅-圆.ttf";
  };

  meta = {
    description = "Tsanger Qingya font family";

    homepage = [
      "https://tsanger.cn/product/399"
      "https://tsanger.cn/product/398"
    ];

    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Qingya font family.

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

  pname = "tsangertype-tsangerqingya";

  dontUnpack = true;

  srcs = [
    fangSrc
    yuanSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${fangSrc} $fontDir/TsangerQingYa-Fang.ttf
    install -Dm444 ${yuanSrc} $fontDir/TsangerQingYa-Yuan.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "仓耳青雅";

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
        "rounded"
        "sans"
      ];

      vendor = "tsangertype";
    };
  };
}
