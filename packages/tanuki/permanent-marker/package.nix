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

  pname = "tanuki-permanent-marker";
  version = "1.22";

  src = fetchurl {
    hash = "sha256-Z/nvaLBDwDbcjGTMcMJmuVR4U5ePzyCQUKgiHJF2bh8=";
    url = "https://tanukifont.com/download/TanukiMagic_1_22.zip";
  };

  meta = {
    description = "Tanuki Permanent Marker Japanese handwriting font";
    homepage = "https://tanukifont.com/tanuki-permanent-marker";
    license =
      licenses.tanuki-permanent-marker-license;

    longDescription = ''
      Provides Tanuki Permanent Marker, a Japanese handwriting font that
      reproduces rounded strokes drawn with a felt-tip marker. It includes
      hiragana, katakana, Latin characters, numerals, and JIS level 1 and
      level 2 kanji in one regular style.

      Tanukizamurai permits personal and commercial use, including embedding
      in documents and applications. Selling the font or fonts derived from
      it requires permission. General standalone redistribution is not
      explicitly granted.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
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

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tanuki
    install -Dm444 TanukiMagic.ttf $fontDir/TanukiMagic.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "たぬき油性マジック";
      embedding = true;

      languages = [
        "aa"
        "ab"
        "af"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "ba"
        "be"
        "bem"
        "bg"
        "bi"
        "br"
        "bs"
        "bua"
        "ca"
        "ce"
        "ch"
        "chm"
        "co"
        "crh"
        "cs"
        "csb"
        "cv"
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
        "gv"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
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
        "ku-tr"
        "kum"
        "kv"
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
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mjw"
        "mn-mn"
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
        "os"
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "rm"
        "rn"
        "ru"
        "rw"
        "sah"
        "sc"
        "se"
        "sel"
        "sg"
        "sh"
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
        "tyv"
        "uk"
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

      licenseCost = "commercialFree";

      notices = [
        {
          level = "warning";

          text = ''
            たぬき油性マジック 允许免费用于个人及商业用途，包括网页、游戏、应用和 PDF 文档嵌入。未经许可不得出售字体文件或修改、描摹后的字体文件；上游未明确允许一般的单独再分发。
          '';

          url = "https://tanukifont.com/tanuki-permanent-marker";
        }
      ];

      styles = [
        "handwritten"
      ];

      vendor = "tanuki";
    };
  };
}
