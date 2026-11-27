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

  pname = "huozicool-huiwen-fangsong";
  version = "1.002";

  src = fetchurl {
    hash = "sha256-3ZVpeFoFlgVsvUnlZb5pUmKeGw9xxbggxtuU14hmYxo=";
    name = "Huiwen-Fangsong-Regular.ttf";
    url = "https://huozi.cool/newfonts/%C3%A6%C2%B1%C2%87%C3%A6%C2%96%C2%87%C3%A4%C2%BB%C2%BF%C3%A5%C2%AE%C2%8Bv1.002.ttf";
  };

  meta = {
    description = "Huiwen Fangsong retro letterpress font from Huozicool";

    homepage = [
      "https://huozi.cool/"
      "https://huozi.cool/article/1780107161300.html"
    ];

    license = licenses.huozicool-huiwen-license;

    longDescription = ''
      Provides Huiwen Fangsong, a letterpress-style Chinese fangsong
      font from TerryWang and Huozicool based on the 59-4 fangsong
      metal typeface.

      The Huozicool Huiwen Series font license permits free personal
      and commercial use, embedding, free redistribution, and
      modification. Third parties may not charge for providing the
      font or sell the font files standalone or as part of a paid
      resource pack.
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
    install -Dm444 $src $fontDir/Huiwen-Fangsong-Regular.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "汇文仿宋";

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
        "cmn"
        "co"
        "cy"
        "da"
        "de"
        "en"
        "es"
        "eu"
        "fil"
        "fj"
        "fo"
        "fr"
        "fur"
        "fy"
        "gd"
        "gl"
        "gv"
        "hak"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "kj"
        "kwm"
        "lb"
        "lg"
        "li"
        "lij"
        "lzh"
        "mfe"
        "mg"
        "mjw"
        "ms"
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
        "tpi"
        "ts"
        "unm"
        "uz"
        "vo"
        "wa"
        "wae"
        "wo"
        "xh"
        "yap"
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "important";

          text = ''
            汇文系列允许免费商用、嵌入文档或软件设备、自由转发传播及修改衍生，但禁止第三方在任何平台收费提供字体，或将字体文件单独及打包出售牟利。
          '';

          url = "https://huozi.cool/article/1780107161300.html";
        }
      ];

      styles = [
        "fangsong"
        "serif"
      ];

      vendor = "huozicool";
    };
  };
}
