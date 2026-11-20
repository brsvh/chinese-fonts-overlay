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

  pname = "lxgw-pengli-wenkai";
  version = "1.034";

  src = fetchurl {
    hash = "sha256-6CyUaRZSb20wuPzNE3wnaLAqA4E7Nn1Mh7iOwTV1DRo=";
    url = "https://github.com/lxgw/Pengli/releases/download/v${version}/PengliWenKai-Regular.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-PKX9YJVrhoXHN2ivG17dgctZZ/EuuPRAjLjptn1llng=";
    url = "https://raw.githubusercontent.com/lxgw/Pengli/v${version}/OFL.txt";
  };

  meta = {
    description = "Pengli WenKai Traditional Chinese handwriting font";
    homepage = "https://github.com/lxgw/Pengli";
    license = licenses.ofl;

    longDescription = ''
      Provides Pengli WenKai, a Traditional Chinese handwriting font
      derived from LXGW WenKai GB and adjusted for the glyph conventions
      used in printing classical Chinese texts.
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

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${src} $fontDir/PengliWenKai-Regular.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "彭蠡文楷";

      languages = [
        "aa"
        "af"
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
        "ga"
        "gd"
        "gl"
        "gn"
        "gv"
        "ha"
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "hz"
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
        "kl"
        "kr"
        "ku-tr"
        "kw"
        "kwm"
        "la"
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
        "rif"
        "rm"
        "rn"
        "ro"
        "rw"
        "sc"
        "sco"
        "se"
        "sg"
        "sgs"
        "sk"
        "sl"
        "sm"
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
        "szl"
        "tk"
        "tn"
        "to"
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
        "yo"
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "handwritten"
        "kai"
      ];

      vendor = "lxgw";
    };
  };
}
