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

  pname = "chill-g-sans";
  version = "1.102";

  src = fetchurl {
    hash = "sha256-k69GG+t5mQHVl8768fOCZnrSkjDQQmiIA6QFd4qYE4M=";
    url = "https://github.com/Warren2060/ChillGSans/releases/download/v${version}/ChillGSans_Medium.otf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-9gBJwD4fmCbz/sGf4tPRHExQsWJajfQcDttRTc66q0g=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillGSans/978b488cdf266ddb9c7e3084140449a0920b5f8e/OFL.txt";
  };

  meta = {
    description = "Chill G Sans condensed humanist Chinese sans-serif font";

    homepage = [
      "https://github.com/Warren2060/ChillGSans"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill G Sans Medium from ChillType, a narrow Chinese
      sans-serif font derived from Glow Sans and paired with Cabin Latin
      glyphs, tailored for subtitles and editorial typography.
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

    fontDir=$out/share/fonts/opentype/chilltype
    docDir=$out/share/doc/${pname}
    install -Dm444 "$src" "$fontDir/ChillGSans_Medium.otf"
    install -Dm444 ${licenseSrc} "$docDir/OFL.txt"

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉高黑体";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "ast"
        "ay"
        "ayc"
        "az-az"
        "bem"
        "bi"
        "bin"
        "br"
        "bs"
        "ca"
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
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ig"
        "io"
        "is"
        "it"
        "ki"
        "kj"
        "kl"
        "ku-tr"
        "kw"
        "kwm"
        "la"
        "lb"
        "lg"
        "li"
        "lij"
        "lt"
        "lv"
        "lzh"
        "mfe"
        "mg"
        "mh"
        "miq"
        "mjw"
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
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "qu"
        "quz"
        "rm"
        "rn"
        "ro"
        "rw"
        "sc"
        "se"
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
        "yuw"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "hei"
        "sans"
      ];

      vendor = "chilltype";
    };
  };
}
