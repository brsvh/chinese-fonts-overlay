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

  pname = "lxgw-simxihei";
  version = "1.103";

  src = fetchurl {
    hash = "sha256-07eky4VS3d3+I+U3nBn5t08spjwji372iCIIv948weM=";
    url = "https://github.com/lxgw/SimXiZhi/releases/download/v${version}/SimXiHei.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-2vkThtb5pqeOTnNsDAA3XK4wIUrFwdqyR58KBfy2Pt0=";
    url = "https://raw.githubusercontent.com/lxgw/SimXiZhi/v${version}/License.txt";
  };

  readmeSrc = fetchurl {
    hash = "sha256-mW7oHkP+XxE80PrbMFwgV0L3YkSuaDZLKr9uik3kS4U=";
    url = "https://raw.githubusercontent.com/lxgw/SimXiZhi/v${version}/README.md";
  };

  meta = {
    description = "SimXiHei Chinese sans-serif font";
    homepage = "https://github.com/lxgw/SimXiZhi";
    license = licenses.ipa;

    longDescription = ''
      Provides SimXiHei, a Chinese sans-serif font derived from IPA
      Gothic with mainland Chinese glyph shapes and metrics intended for
      documents designed for SimHei.

      The IPA Font License 1.0 permits commercial use. Redistribution
      must preserve the license and provide a way to replace the font
      with the original IPA font; modified versions must use the same
      license.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    src
    version
    ;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${src} $fontDir/SimXiHei.ttf
    install -Dm444 ${licenseSrc} $docDir/License.txt
    install -Dm444 ${readmeSrc} $docDir/README.md

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "新晰黑体";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bg"
        "bi"
        "br"
        "ch"
        "cmn"
        "co"
        "da"
        "de"
        "en"
        "es"
        "et"
        "eu"
        "fi"
        "fil"
        "fj"
        "fo"
        "fr"
        "fur"
        "fy"
        "gd"
        "gl"
        "gv"
        "hak"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "kj"
        "kum"
        "kwm"
        "lb"
        "li"
        "lij"
        "lzh"
        "mfe"
        "mg"
        "mhr"
        "mjw"
        "ms"
        "nan"
        "nb"
        "nds"
        "ng"
        "nhn"
        "niu"
        "nl"
        "nn"
        "no"
        "nr"
        "nso"
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pt"
        "rm"
        "rn"
        "ru"
        "rw"
        "sc"
        "sel"
        "sg"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "tn"
        "tpi"
        "ts"
        "unm"
        "uz"
        "vo"
        "vot"
        "wa"
        "wae"
        "xh"
        "yap"
        "yuw"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "free";

      notices = [
        {
          level = "important";

          text = ''
            嵌入软件、网页或设备并分发本字体时，须遵守 IPA 1.0 的衍生字体再分发条款：提供许可、所需的字体及开发文件，并提供让用户恢复原始 IPA 字体的方法。仅用于 PDF 等文档的显示或打印嵌入适用不同条款。
          '';

          url = "https://github.com/lxgw/lxgw/blob/main/documents/xizhi_embedding_instructions.md";
        }
      ];

      styles = [
        "hei"
        "sans"
      ];

      vendor = "lxgw";
    };
  };
}
