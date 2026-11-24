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

  pname = "ichitenfont-i-ming";
  version = "8.10";

  mingSrc = fetchurl {
    hash = "sha256-y6E7dbBQ1nG2EdAGMUcmLkIeFDWa1FMJSLBw9WER8PM=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.Ming-${version}.ttf";
  };

  mingCpSrc = fetchurl {
    hash = "sha256-HEEaLpe2XCaqoBcHu+BpGVafzXaDyLtdsRSpYmRxBFg=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.MingCP-${version}.ttf";
  };

  mingVarSrc = fetchurl {
    hash = "sha256-uod+0gg1xWIuTL6DtBB+ePEa2RnQJoSR79ANQUGi/Xg=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.MingVar-${version}.ttf";
  };

  mingVarCpSrc = fetchurl {
    hash = "sha256-nTQok7Dt3FuqRjmOueg3QcrYYUPd1JO9uNBCaNeK1Sc=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.MingVarCP-${version}.ttf";
  };

  pmingSrc = fetchurl {
    hash = "sha256-S8r/beZ1yreRKgHFCKpJsBvM2s/yY8njFlf34vghBG4=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/PMingI.U-${version}.ttf";
  };

  pmingVarSrc = fetchurl {
    hash = "sha256-/3Qi3ibNFiVoF4omErrt99QJsZGHCl8MkeAKUXMQBc4=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/PMingI.UVar-${version}.ttf";
  };

  meta = {
    description = "I.Ming Traditional Chinese serif fonts";
    homepage = "https://github.com/ichitenfont/I.Ming";
    license = licenses.ipa;

    longDescription = ''
      Provides I.Ming, I.MingCP, I.MingVar, I.MingVarCP, PMingI.U, and
      PMingI.UVar. These related serif fonts offer traditional printed
      Chinese forms, alternate glyphs, punctuation metrics, and Windows
      font-matching variants.
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
    mingSrc
    mingCpSrc
    mingVarSrc
    mingVarCpSrc
    pmingSrc
    pmingVarSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/ichitenfont
    install -Dm444 ${mingSrc} $fontDir/I.Ming.ttf
    install -Dm444 ${mingCpSrc} $fontDir/I.MingCP.ttf
    install -Dm444 ${mingVarSrc} $fontDir/I.MingVar.ttf
    install -Dm444 ${mingVarCpSrc} $fontDir/I.MingVarCP.ttf
    install -Dm444 ${pmingSrc} $fontDir/PMingI.U.ttf
    install -Dm444 ${pmingVarSrc} $fontDir/PMingI.UVar.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "I.Ming（一點明體）";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "be"
        "bem"
        "bg"
        "bi"
        "br"
        "bs"
        "ca"
        "ce"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "da"
        "de"
        "dsb"
        "el"
        "en"
        "eo"
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
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ik"
        "io"
        "is"
        "it"
        "ja"
        "ki"
        "kj"
        "kl"
        "ku-tr"
        "kum"
        "kw"
        "kwm"
        "la"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "lt"
        "lv"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mjw"
        "mk"
        "mo"
        "ms"
        "mt"
        "na"
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
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sc"
        "se"
        "sel"
        "sg"
        "sgs"
        "sk"
        "sl"
        "sm"
        "sma"
        "smj"
        "smn"
        "sn"
        "sq"
        "sr"
        "ss"
        "st"
        "sv"
        "sw"
        "szl"
        "tk"
        "tn"
        "to"
        "tpi"
        "tr"
        "ts"
        "ty"
        "uk"
        "unm"
        "uz"
        "vo"
        "vot"
        "wa"
        "wae"
        "wen"
        "wo"
        "xh"
        "yap"
        "yuw"
        "za"
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

          url = "https://moji.or.jp/ipafont/license/";
        }
      ];

      styles = [
        "serif"
        "song"
      ];

      vendor = "ichitenfont";
    };
  };
}
