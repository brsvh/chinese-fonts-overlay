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

  pname = "lxgw-b5xihei";
  version = "1.003";

  src = fetchurl {
    hash = "sha256-6+78rPnY4eMu1Q3tWFrTG1a6rne+MIUERgukZdpo3II=";
    url = "https://github.com/lxgw/B5XiZhi/releases/download/v${version}/B5XiHei.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-2vkThtb5pqeOTnNsDAA3XK4wIUrFwdqyR58KBfy2Pt0=";
    url = "https://raw.githubusercontent.com/lxgw/B5XiZhi/v${version}/License.txt";
  };

  readmeSrc = fetchurl {
    hash = "sha256-tBr0j+2CjWfZwi2LxTXG+23Wyq+k80xHHKfgEHt41Sc=";
    url = "https://raw.githubusercontent.com/lxgw/B5XiZhi/v${version}/README.md";
  };

  meta = {
    description = "B5XiHei Traditional Chinese sans-serif font";
    homepage = "https://github.com/lxgw/B5XiZhi";
    license = licenses.ipa;

    longDescription = ''
      Provides B5XiHei, a Traditional Chinese sans-serif font with
      Big5-Eten coverage and metrics intended for use in documents
      designed for MingLiU.

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
    install -Dm444 ${src} $fontDir/B5XiHei.ttf
    install -Dm444 ${licenseSrc} $docDir/License.txt
    install -Dm444 ${readmeSrc} $docDir/README.md

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "Ｂ５晰黑體";

      languages = [
        "bem"
        "bg"
        "cmn"
        "fj"
        "hak"
        "ho"
        "ia"
        "io"
        "kj"
        "kum"
        "kwm"
        "lzh"
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
        "zh-tw"
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
