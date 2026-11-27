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

  version = "26200.6584.250915-1905";

  src = fetchurl {
    hash = "sha256-e0rIc5G2WfdyQiloK2QiViiaHABQQFYknw8SApFX09I=";
    url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_zh-cn.iso";
  };

  meta = {
    description = "Microsoft Windows 11 zh-CN font collection";
    homepage = "https://learn.microsoft.com/en-us/typography/fonts/windows_11_font_list";
    license = licenses.microsoft-software-license;

    longDescription = ''
      Provides the Microsoft Windows 11 zh-CN font collection.

      Obtain a valid license under the Microsoft Software License
      Terms before use. After obtaining it, do not redistribute the
      font files or publish them through a binary cache unless that
      license permits it.
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

  pname = "windows-fonts";

  nativeBuildInputs = [
    p7zip
  ];

  preferLocalBuild = true;

  unpackPhase = ''
    runHook preUnpack

    tempdir=$(mktemp -d)

    7z x $src -o$tempdir

    mkdir fonts licenses

    7z e \
      $tempdir/sources/install.wim \
      Windows/Fonts/"*".ttf \
      Windows/Fonts/"*".ttc \
      -ofonts

    7z e \
      $tempdir/sources/install.wim \
      Windows/System32/zh-CN/Licenses/Eval/EnterpriseEval/license.rtf \
      -olicenses

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 fonts/* \
      -t $out/share/fonts/truetype/microsoft

    install -Dm444 \
      licenses/license.rtf \
      $out/share/doc/windows-fonts/license.rtf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "Windows 字体";

      languages = [
        "aa"
        "ab"
        "ae"
        "af"
        "agr"
        "aho"
        "ak"
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
        "ja"
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
        "ko"
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
        "ty"
        "tyv"
        "ug"
        "uga"
        "uk"
        "und-zmth"
        "und-zsye"
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
        "zh-tw"
        "zu"
      ];

      licenseCost = "paid";

      notices = [
        {
          level = "caution";

          text = ''
            Microsoft 字体是专有软件，受 Microsoft Software License Terms 约束。 这个仓库只提供本地构建与安装表达式，不授予额外使用或再分发权利。

            相关限制可以概括为：您不能在非 Windows 设备上使用它们。

            建议您只在 Windows Subsystem for Linux (WSL) 上使用它。
          '';
        }
      ];

      styles = [
        "art"
        "cal"
        "fangsong"
        "handwritten"
        "hei"
        "kai"
        "mono"
        "sans"
        "serif"
        "song"
        "symbol"
      ];

      vendor = "microsoft";
    };

    isFontAggregate = true;
  };
}
