{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    licenses
    maintainers
    mapAttrs
    mapAttrsToList
    platforms
    ;

  pname = "chill-matrix";
  version = "2.000-ultra";
  baseUrl = "https://github.com/Warren2060/ChillMatrix/releases/download/v2.000Ultra";

  fontHashes = {
    "ChillMatrix-Demi.otf" =
      "sha256-JoOv4b6uMmx4qRxvIUiBe1ctAZ+efWJvzgmcxi/FjUY=";
    "ChillMatrix-Normal.otf" =
      "sha256-s8OgLpZXz498VQTsHyYGBkmqQLiBRLprtwkbb2BqjfY=";
    "ChillMatrix-Ultra.otf" =
      "sha256-jnn8sBR1C6B3vEqckUt0q1rYBrFH7yKASqkfpkCQk2M=";
  };

  fontSrcs = mapAttrs (
    name: hash:
    fetchurl {
      inherit hash;

      url = "${baseUrl}/${name}";
    }
  ) fontHashes;

  meta = {
    description = "Chill Matrix pixel-matrix display Chinese fonts";

    homepage = [
      "https://github.com/Warren2060/ChillMatrix"
    ];

    license = licenses.chilltype-matrix-license;

    longDescription = ''
      Provides Chill Matrix from ChillType, a rectangular pixel-matrix
      display Chinese family in Normal, Demi, and Ultra OpenType variants.

      Per the Chill Matrix license agreement bundled in release v2.0, the
      font is free for personal non-commercial use, public-interest use,
      and physical storefront signage. Other personal and enterprise
      commercial uses require a paid license; modification, format
      conversion, and resale are prohibited, and redistribution is not
      granted.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    version
    ;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/chilltype
    ${concatStringsSep "\n    " (
      mapAttrsToList (
        name: src:
        "install -Dm444 ${src} $fontDir/${name}"
      ) fontSrcs
    )}

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉矩阵体";

      languages = [
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
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "gratisPersonalUse";

      notices = [
        {
          level = "warning";

          text = ''
            依据 v2.0 压缩包内附《寒蝉矩阵体使用协议》，本字体个人非商用免费，且允许免费用于线下门店商户招牌及公益用途；其他个人商用与企业商用均需联系作者购买永久授权。协议严禁修改字体、变更格式或转售，且未授予再分发权限。
          '';

          url = "https://github.com/Warren2060/ChillMatrix/releases/tag/v2.0";
        }
      ];

      styles = [
        "art"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  srcs = attrValues fontSrcs;
}
