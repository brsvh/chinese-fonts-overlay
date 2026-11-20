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

  pname = "lxgw-neo-zhisong";
  version = "1.070";
  screenVersion = "26.08.21";

  regularSrc = fetchurl {
    hash = "sha256-xCAAtZyv/ozPzRyQqihB3K+oZs8kdpzBsQw3CMZx8gc=";
    url = "https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${version}/LXGWNeoZhiSong.ttf";
  };

  plusSrc = fetchurl {
    hash = "sha256-MBHawdaPffIsmuSpG+7TI91yZsCynanxxUAkJSK2jww=";
    url = "https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${version}/LXGWNeoZhiSongPlus.ttf";
  };

  screenSrc = fetchurl {
    hash = "sha256-TgcbY+4iHnIwnscgJZ8mQCQzaZHR7gvOQugNH7OFWhw=";
    url = "https://github.com/lxgw/LxgwNeoXiZhi-Screen/releases/download/${screenVersion}/LXGWNeoZhiSongScreen.ttf";
  };

  screenFullSrc = fetchurl {
    hash = "sha256-nQSAgEsXkDfotQ+rjk6OxROdYtIz/Sp3iQXHLk3J9Bc=";
    url = "https://github.com/lxgw/LxgwNeoXiZhi-Screen/releases/download/${screenVersion}/LXGWNeoZhiSongScreenFull.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-FIPH3gLc+LnFSzsarKv31r3zLUEspnJMApLqaOhi2M8=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwNeoZhiSong/v${version}/LICENSE.md";
  };

  readmeSrc = fetchurl {
    hash = "sha256-SkgP1hEbvrVT0zCVTbDA+gx83V4qUyBVaaOmLtdAXec=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwNeoZhiSong/v${version}/README.md";
  };

  screenLicenseSrc = fetchurl {
    hash = "sha256-2vkThtb5pqeOTnNsDAA3XK4wIUrFwdqyR58KBfy2Pt0=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwNeoXiZhi-Screen/${screenVersion}/IPA_Font_License_Agreement_v1.0.txt";
  };

  screenNoticesSrc = fetchurl {
    hash = "sha256-2OA/tsS+IdRXN3CB7m8f7q8wEFEs+pdzAlzijX7mgSE=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwNeoXiZhi-Screen/${screenVersion}/licenses_of_other_incorporated_fonts.txt";
  };

  screenReadmeSrc = fetchurl {
    hash = "sha256-e/aAsHJc3FpUF00B9lUAzd7sY8A54XoB4W3y6j888KY=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwNeoXiZhi-Screen/${screenVersion}/README.md";
  };

  meta = {
    description = "LXGW Neo ZhiSong Chinese serif fonts";
    homepage = "https://github.com/lxgw/LxgwNeoZhiSong";
    license = licenses.ipa;

    longDescription = ''
      Provides LXGW Neo ZhiSong and Neo ZhiSong Plus together with the
      Screen and Screen Full variants for screen reading. The Screen
      variants retain their final 26.08.21 release, based on Neo ZhiSong
      1.067.

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
    version
    ;

  dontUnpack = true;

  srcs = [
    regularSrc
    plusSrc
    screenSrc
    screenFullSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${regularSrc} $fontDir/LXGWNeoZhiSong.ttf
    install -Dm444 ${plusSrc} $fontDir/LXGWNeoZhiSongPlus.ttf
    install -Dm444 ${screenSrc} $fontDir/LXGWNeoZhiSongScreen.ttf
    install -Dm444 ${screenFullSrc} $fontDir/LXGWNeoZhiSongScreenFull.ttf
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md
    install -Dm444 ${readmeSrc} $docDir/README.md
    install -Dm444 ${screenLicenseSrc} $docDir/Screen-IPA-License.txt
    install -Dm444 ${screenNoticesSrc} $docDir/Screen-Incorporated-Licenses.txt
    install -Dm444 ${screenReadmeSrc} $docDir/Screen-README.md

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "霞鹜新致宋";

      languages = [
        "aa"
        "ab"
        "af"
        "agr"
        "ak"
        "an"
        "ast"
        "av"
        "ay"
        "ayc"
        "az-az"
        "ba"
        "be"
        "bem"
        "ber-dz"
        "bg"
        "bi"
        "bin"
        "bm"
        "br"
        "bs"
        "bua"
        "ca"
        "ce"
        "ch"
        "chm"
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
        "cu"
        "cv"
        "cy"
        "da"
        "de"
        "dsb"
        "ee"
        "el"
        "en"
        "eo"
        "es"
        "et"
        "eu"
        "fat"
        "ff"
        "fi"
        "fil"
        "fj"
        "fo"
        "fr"
        "fur"
        "fy"
        "ga"
        "gd"
        "gl"
        "gn"
        "gv"
        "ha"
        "hak"
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "hz"
        "ia"
        "id"
        "ie"
        "ig"
        "ik"
        "io"
        "is"
        "it"
        "ja"
        "kaa"
        "kab"
        "ki"
        "kj"
        "kk"
        "kl"
        "ko"
        "kr"
        "ku-am"
        "ku-tr"
        "kum"
        "kv"
        "kw"
        "kwm"
        "ky"
        "la"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "lis"
        "ln"
        "lt"
        "lv"
        "lzh"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mi"
        "miq"
        "mjw"
        "mk"
        "mn-mn"
        "mo"
        "ms"
        "mt"
        "na"
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
        "nv"
        "ny"
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "qu"
        "quz"
        "rif"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sah"
        "sc"
        "sco"
        "se"
        "sel"
        "sg"
        "sgs"
        "sh"
        "shs"
        "sk"
        "sl"
        "sm"
        "sma"
        "smj"
        "smn"
        "sms"
        "sn"
        "sq"
        "sr"
        "ss"
        "st"
        "sv"
        "sw"
        "szl"
        "tg"
        "tk"
        "tn"
        "to"
        "tpi"
        "tr"
        "ts"
        "tt"
        "tw"
        "ty"
        "tyv"
        "uk"
        "unm"
        "uz"
        "ve"
        "vi"
        "vo"
        "vot"
        "wa"
        "wae"
        "wen"
        "wo"
        "xh"
        "yap"
        "yo"
        "yuw"
        "za"
        "zh-cn"
        "zh-sg"
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
        "serif"
        "song"
      ];

      vendor = "lxgw";
    };
  };
}
