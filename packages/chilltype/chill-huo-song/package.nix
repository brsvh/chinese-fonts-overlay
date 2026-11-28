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

  pname = "chill-huo-song";
  version = "1.000";

  src = fetchurl {
    hash = "sha256-4xh1GdIS8/GNsZLLtOhn/rEksU4F0KCGRzFahf0Ye8E=";
    url = "https://github.com/Warren2060/ChillMovableType/releases/download/HuoSongv${version}/ChillHuoSong_F.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-x8ZpEx6CC0vW2ZFaS1bJVna8/43d7zcW4ijvBiVObT8=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillMovableType/d0a36cfb5912e891c0492d3ff5c04584e05b9409/LICENSE";
  };

  meta = {
    description = "Chill Huo Song movable-type letterpress Chinese serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillMovableType"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Huo Song from the ChillType ChillMovableType project, a
      letterpress-textured Chinese serif family derived from Shippori Mincho
      and Chill Jinshu Mincho B2. Includes four OpenType styles: Regular,
      ConRegular, Bold, and ExBold.
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
    install -Dm444 ${licenseSrc} "$docDir/LICENSE"

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉活宋体";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bi"
        "br"
        "ch"
        "da"
        "de"
        "en"
        "es"
        "eu"
        "fil"
        "fj"
        "fo"
        "fur"
        "fy"
        "gd"
        "gl"
        "gv"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "ja"
        "kj"
        "kwm"
        "lb"
        "li"
        "lij"
        "mg"
        "mjw"
        "ms"
        "nb"
        "nds"
        "ng"
        "nl"
        "nn"
        "no"
        "nr"
        "oc"
        "om"
        "pap-an"
        "pap-aw"
        "pt"
        "rm"
        "rn"
        "rw"
        "sc"
        "sg"
        "sm"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "to"
        "tpi"
        "ts"
        "unm"
        "uz"
        "vo"
        "wa"
        "wae"
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
        "serif"
        "song"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
