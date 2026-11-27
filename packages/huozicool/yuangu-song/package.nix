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

  pname = "huozicool-yuangu-song";
  version = "3.000";

  src = fetchurl {
    hash = "sha256-MKgz+MuApujMjAqGb/ZicVz++aulQkCtAgU3a54SdEg=";
    name = "YuanGuSongTGC-Book.ttf";
    url = "https://huozi.cool/newfonts/YGS.ttf";
  };

  meta = {
    description = "YuanGu Song ancient-book table serif font from Huozicool";

    homepage = [
      "https://huozi.cool/"
      "https://huozi.cool/article/1780107438940.html"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides YuanGu Song (table-only edition), a Source Han Serif
      derivative from TerryWang and Huozicool tailored to the GB/Z
      40637-2021 standard ancient-book printing glyph table, with CJK
      Extension B glyphs supplemented from WenJin Mincho.
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
    install -Dm444 $src $fontDir/YuanGuSongTGC-Book.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "源古宋体";

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
        "zu"
      ];

      licenseCost = "free";

      notices = [
        {
          level = "note";

          text = ''
            此版本仅收录《古籍印刷通用字规范字形表》（GB/Z 40637-2021）表内汉字及基本字符，适合作为古籍表字形参考或造字底本；日常阅读与排版请选用“源古宋体-完整版”。
          '';

          url = "https://huozi.cool/article/1780107438940.html";
        }
      ];

      styles = [
        "serif"
        "song"
      ];

      vendor = "huozicool";
    };
  };
}
