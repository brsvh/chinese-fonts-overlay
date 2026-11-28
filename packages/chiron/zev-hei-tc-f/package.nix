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

  pname = "chiron-zev-hei-tc-f";
  version = "0.008-unstable-2026-10-18";
  rev = "c01e0591d329ee40da951c0e73e977095c4643fa";
  baseUrl = "https://raw.githubusercontent.com/chiron-fonts/zev-hei-tc/${rev}";

  src = fetchurl {
    hash = "sha256-g6VCuRtT/DcuDn2fN7ICmT4o/VrJRy6i5kuEi9YFDQw=";
    url = "${baseUrl}/VAR_OTF/ZevHeiTC-F-VF.otf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-kVmDVRfQI7FCycfKwzVEdIlXfJFEyAK8/a4w1jc5Oqg=";
    url = "${baseUrl}/LICENSE.md";
  };

  meta = {
    description = "ZevHeiTC-F geometric Traditional Chinese variable sans-serif font";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/zev-hei-tc"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides ZevHeiTC-F, the footed geometric variable OpenType variant
      of Zev Hei TC from Chiron Fonts, derived from Chiron Hei HK and
      Mona Sans. Supports wght, wdth, and IDSP axes while retaining
      bottom stroke feet.
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

    fontDir=$out/share/fonts/opentype/chiron
    docDir=$out/share/doc/${pname}
    install -Dm444 ${src} $fontDir/ZevHeiTC-F-VF.otf
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "宙黑體 F";

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
        "ja"
        "ki"
        "kj"
        "ko"
        "ku-tr"
        "kum"
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
        "mhr"
        "miq"
        "mjw"
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
            F 版保留字形底部承托腳特徵，上游僅提供可變字體（支援 wght、wdth 與 IDSP 軸）。75% 至 120% 字形寬度由程式自動調整，未經人工微調。
          '';

          url = "https://github.com/chiron-fonts/zev-hei-tc";
        }
      ];

      styles = [
        "hei"
        "sans"
      ];

      vendor = "chiron";
    };
  };
}
