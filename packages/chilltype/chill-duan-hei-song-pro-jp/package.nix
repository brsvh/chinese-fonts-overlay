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

  pname = "chill-duan-hei-song-pro-jp";
  version = "1.200";

  src = fetchurl {
    hash = "sha256-qRplNl0YbiZBuQ2Z30jdB630yYeQpz+FcfjlFaNp6h4=";
    url = "https://github.com/Warren2060/ChillDuanHeiSong/releases/download/v${version}/ChillDuanHeiSongPro_v1.2.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-yLHzfTiwLjgTzpt79g0NwEZGowvP6N4qce+BurFeMGg=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillDuanHeiSong/39c03ffb1f5c563165539e06d234db8e3b784a29/LICENSE";
  };

  meta = {
    description = "Chill Duan Hei Song Pro JP Japanese hybrid serif-sans font";

    homepage = [
      "https://github.com/Warren2060/ChillDuanHeiSong"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Duan Hei Song Pro JP from ChillType, the Japanese
      Regular OpenType edition of Chill Duan Hei Song Pro.
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
    find . -type f -name 'ChillDuanHeiSongProJP_Regular.otf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    install -Dm444 ${licenseSrc} "$docDir/LICENSE"

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉端黑宋 Pro JP";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bg"
        "bi"
        "bin"
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
        "gn"
        "gv"
        "haw"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "ig"
        "io"
        "is"
        "it"
        "ja"
        "ki"
        "kj"
        "kum"
        "kwm"
        "lb"
        "li"
        "lij"
        "mg"
        "mhr"
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
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pt"
        "rm"
        "rn"
        "ru"
        "rw"
        "sc"
        "sel"
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
        "hei"
        "serif"
        "song"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
