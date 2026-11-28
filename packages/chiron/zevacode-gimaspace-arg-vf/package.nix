{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  pname = "chiron-zevacode-gimaspace-arg-vf";
  version = "2026-05-29";

  src = fetchurl {
    hash = "sha256-i9ny44rRWTOe92iwA/Qr66sYWgr0xLW26BrhpqEANmk=";
    url = "https://github.com/chiron-fonts/ZevaCode/releases/download/${version}/ZevaCode-Gimaspace-Variable.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-ZBrvEJTrvI4e8SH+ssBaAnWdEHlCpPjGDi6SoYLVqlo=";
    url = "https://raw.githubusercontent.com/chiron-fonts/ZevaCode/${version}/LICENSE.md";
  };

  meta = {
    description = "ZevaCode GimaspaceArg variable monospace fonts with ZevHeiTC-N CJK";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/ZevaCode"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides ZevaCode GimaspaceArg variable TrueType fonts combining
      Monaspace Argon with ZevHeiTC-N CJK glyphs in aligned (Al) and
      original-width (Og) variants.
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

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/chiron
    docDir=$out/share/doc/${pname}
    install -Dm444 -t $fontDir ZevaCode-*-GimaspaceArg-Variable.ttf
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "ZevaCode GimaspaceArg VF";

      languages = [
        "aa"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "az-az"
        "be"
        "bem"
        "bg"
        "bi"
        "bin"
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
        "cy"
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
        "gn"
        "gv"
        "hak"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
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
        "ki"
        "kj"
        "kk"
        "kl"
        "ko"
        "ku-tr"
        "kum"
        "kw"
        "kwm"
        "ky"
        "la"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "lt"
        "lv"
        "lzh"
        "mfe"
        "mg"
        "mh"
        "mhr"
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
        "tg"
        "tk"
        "tn"
        "tpi"
        "tr"
        "ts"
        "tt"
        "ty"
        "tyv"
        "uk"
        "unm"
        "uz"
        "vi"
        "vo"
        "vot"
        "wa"
        "wae"
        "wen"
        "wo"
        "xh"
        "yap"
        "yue"
        "yuw"
        "za"
        "zh-cn"
        "zh-hk"
        "zh-mo"
        "zh-sg"
        "zh-tw"
        "zu"
      ];

      licenseCost = "free";

      notices = [
        {
          level = "note";

          text = ''
            本套件同時包含 Al（盡力對齊拉丁字寬兩倍，僅於 100% 字寬有效）與 Og（保留原中文字寬）兩種可變字體變體。中文字圖直接複製自宙黑體 ZevHeiTC-N，不含中文 OpenType 排版特性且不支援直排。
          '';

          url = "https://github.com/chiron-fonts/ZevaCode";
        }
      ];

      styles = [
        "hei"
        "mono"
        "sans"
      ];

      vendor = "chiron";
    };
  };

  sourceRoot = ".";
}
