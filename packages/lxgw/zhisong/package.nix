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

  pname = "lxgw-zhisong";
  version = "1.002";

  classicSrc = fetchurl {
    hash = "sha256-YiOPJTq21Ys4CCpcdbYJQJ0FwU9XNyB8lO0uTMAjgSs=";
    url = "https://github.com/lxgw/LxgwZhiSong/releases/download/v${version}/LXGWZhiSongCL.ttf";
  };

  modernSrc = fetchurl {
    hash = "sha256-lNnlobL3tD343WLfdy406YTGz8npR6IW44G0dyus0oM=";
    url = "https://github.com/lxgw/LxgwZhiSong/releases/download/v${version}/LXGWZhiSongMN.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-GOY54dXVdcuSaUx5sq7ReBojTrW+QgDBR5psJ+Ef3cw=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhiSong/v${version}/LICENSE.md";
  };

  readmeSrc = fetchurl {
    hash = "sha256-5kpDkxSHL6psOhMt8RB5BNtAupDmIFj7Znoy96wF1KE=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhiSong/v${version}/README.md";
  };

  meta = {
    description = "LXGW ZhiSong Traditional Chinese serif fonts";
    homepage = "https://github.com/lxgw/LxgwZhiSong";
    license = licenses.ipa;

    longDescription = ''
      Provides the Classic and Modern variants of LXGW ZhiSong, a
      Traditional Chinese serif family derived from IPAex Mincho.
      Classic follows traditional printed forms and merges selected
      source-separated characters; Modern balances printed forms with
      contemporary component conventions and preserves those characters.

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
    classicSrc
    modernSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${classicSrc} $fontDir/LXGWZhiSongCL.ttf
    install -Dm444 ${modernSrc} $fontDir/LXGWZhiSongMN.ttf
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md
    install -Dm444 ${readmeSrc} $docDir/README.md

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "霞鶩緻宋";

      languages = [
        "aa"
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
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
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
        "sc"
        "sco"
        "se"
        "sel"
        "sg"
        "sgs"
        "sh"
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
