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

  pname = "chill-moon-mono";
  version = "1.000";

  src = fetchurl {
    hash = "sha256-zMqX47hP2VLk0oKWzDriDut3YYT3PBv0KTzjhlYZWJE=";
    url = "https://github.com/Warren2060/ChillMoonmono/releases/download/v${version}/ChillMoonMono.zip";
  };

  meta = {
    description = "ChillMoon Mono humanist pixel monospace font";

    homepage = [
      "https://github.com/Warren2060/ChillMoonmono"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides ChillMoon Mono from ChillType, an original humanist monospace
      pixel OpenType font with handwritten nuances.
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

    fontDir=$out/share/fonts/opentype/chilltype
    docDir=$out/share/doc/${pname}
    find . -type f -name '*.otf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    find . -type f -name 'license.txt' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 {} "$docDir/LICENSE.txt" \;

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "ChillMoon Mono";

      languages = [
        "aa"
        "agr"
        "ak"
        "an"
        "ast"
        "ay"
        "ayc"
        "az-az"
        "bem"
        "ber-dz"
        "bi"
        "bin"
        "bm"
        "br"
        "bs"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
        "ee"
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
        "gd"
        "gl"
        "gn"
        "gv"
        "ha"
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
        "kab"
        "ki"
        "kj"
        "ku-tr"
        "kw"
        "kwm"
        "lb"
        "lg"
        "li"
        "lij"
        "ln"
        "lt"
        "lv"
        "mfe"
        "mg"
        "mh"
        "mi"
        "miq"
        "mjw"
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
        "sma"
        "smj"
        "smn"
        "sms"
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
        "tw"
        "ty"
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
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "art"
        "mono"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
