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

  pname = "naver-maru-buri";
  version = "1.000";

  src = fetchurl {
    hash = "sha256-cxNujd+DwO972Afv7sBjk9bXZ4SH1TZy3/nsk/cdG9A=";
    url = "https://hangeul.naver.com/hangeul_static/webfont/zips/maruburi.zip";
  };

  meta = {
    description = "Maru Buri Korean serif font family";

    homepage = [
      "https://hangeul.naver.com/maruproject_11"
      "https://hangeul.naver.com/fonts/search?f=maru"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Maru Buri, a Korean serif family from NAVER and the NAVER
      Cultural Foundation, designed by AG Typography Institute for reading
      on digital screens. Includes the ExtraLight, Light, Regular, SemiBold,
      and Bold weights in TrueType format, with Hangul syllables and Latin
      characters.
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

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack

    unzip -j "$src" '*/MaruBuriTTF.zip'
    unzip MaruBuriTTF.zip

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/naver MaruBuri-*.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "마루 부리";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bi"
        "br"
        "bs"
        "ca"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
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
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "kj"
        "ko"
        "ku-tr"
        "kwm"
        "lb"
        "lg"
        "li"
        "lij"
        "lt"
        "lv"
        "mfe"
        "mg"
        "mh"
        "mjw"
        "ms"
        "mt"
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
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
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
        "sma"
        "smj"
        "smn"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "tk"
        "tn"
        "tpi"
        "tr"
        "ts"
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
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "serif"
        "song"
      ];

      vendor = "naver";
    };
  };
}
