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

  pname = "huozicool-yuangu-song-f";
  version = "2.004";

  src = fetchurl {
    hash = "sha256-orHKuiV+9A+K/NBPCI9topbpANn6GdTslFvpG1Y387E=";
    name = "YuanGuSongTGCF-Book.ttf";
    url = "https://huozi.cool/newfonts/YGSF.ttf";
  };

  meta = {
    description = "YuanGu Song full-coverage ancient-book serif font from Huozicool";

    homepage = [
      "https://huozi.cool/"
      "https://huozi.cool/article/1780107438940.html"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides YuanGu Song Full (F edition), a Source Han Serif
      derivative from TerryWang and Huozicool tailored to the GB/Z
      40637-2021 standard ancient-book printing glyph table while
      retaining the remaining Source Han Serif glyphs for general
      reading and writing.
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

    fontDir=$out/share/fonts/truetype/huozicool
    install -Dm444 $src $fontDir/YuanGuSongTGCF-Book.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "源古宋体-完整版";

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
        "cmn"
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
        "hak"
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
        "lzh"
        "mg"
        "mhr"
        "miq"
        "mjw"
        "ms"
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
        "zh-tw"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "serif"
        "song"
      ];

      vendor = "huozicool";
    };
  };
}
