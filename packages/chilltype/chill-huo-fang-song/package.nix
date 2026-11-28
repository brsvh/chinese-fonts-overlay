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

  pname = "chill-huo-fang-song";
  version = "0.100";

  src = fetchurl {
    hash = "sha256-tg+Vt8tcUaO/4Up4kiv6hTuObLmioAaXfBjHpU8YSZs=";
    url = "https://github.com/Warren2060/ChillMovableType/releases/download/HuoFangSongv${version}/ChillHuoFangSong.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-x8ZpEx6CC0vW2ZFaS1bJVna8/43d7zcW4ijvBiVObT8=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillMovableType/d0a36cfb5912e891c0492d3ff5c04584e05b9409/LICENSE";
  };

  meta = {
    description = "Chill Huo FangSong movable-type letterpress Chinese FangSong fonts";

    homepage = [
      "https://github.com/Warren2060/ChillMovableType"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Huo FangSong from the ChillType ChillMovableType
      project, a letterpress-textured Chinese FangSong family derived from
      Zhuque Fangsong and Simonetta. Includes three OpenType styles:
      Regular, ConRegular, and ConBold.
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
      displayName = "寒蝉活仿宋";

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
        "co"
        "cs"
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
        "gn"
        "gv"
        "ho"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "ki"
        "kj"
        "kwm"
        "lb"
        "li"
        "lij"
        "mfe"
        "mg"
        "miq"
        "mjw"
        "ms"
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
        "pt"
        "rm"
        "rn"
        "rw"
        "sc"
        "sg"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "tn"
        "tpi"
        "ts"
        "unm"
        "uz"
        "vo"
        "vot"
        "wa"
        "wae"
        "xh"
        "yap"
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "fangsong"
        "serif"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
