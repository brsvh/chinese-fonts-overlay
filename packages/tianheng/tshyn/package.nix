{
  fetchurl,
  lib,
  p7zip,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "5.0.0";

  src = fetchurl {
    hash = "sha256-cqYgRfj3busbxVuQbKYdD+jcx3mDkfUrtFgQDpEdazM=";
    url = "http://cheonhyeong.com/File/TH-Tshyn-${version}.7z";
  };

  meta = {
    description = "TH-Tshyn full font collection from TianHeng fonts";
    homepage = "http://cheonhyeong.com/Simplified/download.html";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Tshyn full font collection.

      This package treats the fonts as non-redistributable because
      the glyph copyright status is unclear. Do not redistribute the
      font files or publish them through a binary cache.
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

  pname = "tianheng-tshyn";

  nativeBuildInputs = [
    p7zip
  ];

  unpackPhase = ''
    runHook preUnpack

    7z e $src -y \
      TH-Times.ttc \
      TH-Tshyn-P0.ttf \
      TH-Tshyn-P1.ttf \
      TH-Tshyn-P2.ttf \
      TH-Tshyn-P16.ttf

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/tianheng \
      TH-Times.ttc \
      TH-Tshyn-P0.ttf \
      TH-Tshyn-P1.ttf \
      TH-Tshyn-P2.ttf \
      TH-Tshyn-P16.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "天珩全字库";

      languages = [
        "aa"
        "ab"
        "ae"
        "af"
        "agr"
        "aho"
        "ak"
        "akk"
        "am"
        "an"
        "anp"
        "ar"
        "arc"
        "as"
        "ast"
        "av"
        "ay"
        "ayc"
        "az-az"
        "az-ir"
        "ba"
        "ban"
        "bax"
        "be"
        "bem"
        "ber-dz"
        "ber-ma"
        "bg"
        "bh"
        "bhb"
        "bho"
        "bi"
        "bin"
        "bku"
        "blt"
        "bm"
        "bn"
        "bo"
        "br"
        "brx"
        "bs"
        "bua"
        "byn"
        "ca"
        "ccp"
        "ce"
        "ch"
        "chm"
        "chr"
        "cjm"
        "ckb"
        "cmn"
        "co"
        "cop"
        "crh"
        "cs"
        "csb"
        "cu"
        "cv"
        "cy"
        "da"
        "de"
        "dmf"
        "doi"
        "dsb"
        "dv"
        "dz"
        "ecy"
        "ee"
        "egy"
        "eky"
        "el"
        "en"
        "eo"
        "es"
        "et"
        "ett"
        "eu"
        "fa"
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
        "gez"
        "gl"
        "gmy"
        "gn"
        "got"
        "gu"
        "gv"
        "ha"
        "hak"
        "haw"
        "he"
        "hi"
        "hif"
        "hit"
        "hlu"
        "hmd"
        "hne"
        "hnn"
        "ho"
        "hoc"
        "hr"
        "hsb"
        "ht"
        "hu"
        "hy"
        "hz"
        "ia"
        "id"
        "ie"
        "ig"
        "ii"
        "ik"
        "io"
        "is"
        "it"
        "iu"
        "jv"
        "ka"
        "kaa"
        "kab"
        "kaw"
        "khb"
        "ki"
        "kj"
        "kk"
        "kl"
        "km"
        "kn"
        "kok"
        "kr"
        "ks"
        "ku-am"
        "ku-iq"
        "ku-ir"
        "ku-tr"
        "kum"
        "kv"
        "kw"
        "kwm"
        "ky"
        "la"
        "lah"
        "lb"
        "lep"
        "lez"
        "lg"
        "li"
        "lif"
        "lij"
        "lis"
        "ln"
        "lo"
        "lt"
        "lv"
        "lzh"
        "mag"
        "mai"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mi"
        "mid"
        "miq"
        "mjw"
        "mk"
        "ml"
        "mn-cn"
        "mn-mn"
        "mni"
        "mnw"
        "mo"
        "mr"
        "mro"
        "ms"
        "mt"
        "my"
        "na"
        "nan"
        "nb"
        "nds"
        "ne"
        "ng"
        "nhn"
        "niu"
        "nl"
        "nn"
        "nnp"
        "no"
        "nqo"
        "nr"
        "nso"
        "nv"
        "ny"
        "oc"
        "om"
        "or"
        "os"
        "osa"
        "ota"
        "otk"
        "oui"
        "pa"
        "pa-pk"
        "pal"
        "pap-an"
        "pap-aw"
        "peo"
        "pgd"
        "pgl"
        "phn"
        "pl"
        "ps-af"
        "ps-pk"
        "pt"
        "qu"
        "quz"
        "raj"
        "rhg"
        "rif"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sa"
        "sah"
        "sam"
        "sat"
        "sc"
        "sco"
        "sd"
        "se"
        "sel"
        "sg"
        "sgs"
        "sh"
        "shn"
        "shs"
        "si"
        "sid"
        "sk"
        "sl"
        "sm"
        "sma"
        "smj"
        "smn"
        "sms"
        "sn"
        "so"
        "sog"
        "sq"
        "sr"
        "ss"
        "st"
        "su"
        "sux"
        "suz"
        "sv"
        "sw"
        "syr"
        "szl"
        "ta"
        "tbw"
        "tcy"
        "tdd"
        "te"
        "tg"
        "th"
        "the"
        "ti-er"
        "ti-et"
        "tig"
        "tk"
        "tl"
        "tn"
        "to"
        "tpi"
        "tr"
        "ts"
        "tt"
        "tw"
        "txg"
        "ty"
        "tyv"
        "ug"
        "uga"
        "uk"
        "und-zmth"
        "unm"
        "ur"
        "uz"
        "vai"
        "ve"
        "vi"
        "vo"
        "vot"
        "wa"
        "wae"
        "wal"
        "wen"
        "wo"
        "xag"
        "xco"
        "xcr"
        "xh"
        "xlc"
        "xld"
        "xmr"
        "xna"
        "xpr"
        "xsa"
        "xzh"
        "yap"
        "yi"
        "yo"
        "yuw"
        "za"
        "zh-cn"
        "zh-sg"
        "zkt"
        "zu"
      ];

      licenseCost = "gratisPersonalUse";

      notices = [
        {
          level = "caution";

          text = ''
            天珩字库中字体的字形来自中易、华康、Iwata、Besta、方正等公司，其字体使用必须用于非盈利、学习研究的用途。

            其具体的版权问题比较复杂，建议仅做本地屏显补字用途。
          '';

          url = "http://cheonhyeong.com/Simplified/download.html";
        }
      ];

      styles = [
        "serif"
        "song"
      ];

      vendor = "tianheng";
    };
  };
}
