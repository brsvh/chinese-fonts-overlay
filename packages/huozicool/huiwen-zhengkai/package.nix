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

  pname = "huozicool-huiwen-zhengkai";
  version = "1.001";

  src = fetchurl {
    hash = "sha256-xVl0B+jr7GFPdcZJ2p0rlZw/+NuaX6B97TgY4qDn0Qk=";
    name = "Huiwen-Zhengkai-Regular.ttf";
    url = "https://huozi.cool/newfonts/HWZHENGKAI.ttf";
  };

  meta = {
    description = "Huiwen Zhengkai retro letterpress kai font from Huozicool";

    homepage = [
      "https://huozi.cool/"
      "https://huozi.cool/article/1780107161300.html"
    ];

    license = licenses.huozicool-huiwen-license;

    longDescription = ''
      Provides Huiwen Zhengkai, a letterpress-style Chinese regular
      script font from TerryWang and Huozicool based on No. 4 Hanwen
      Zhengkai metal type specimens.

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
    install -Dm444 $src $fontDir/Huiwen-Zhengkai-Regular.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "汇文正楷";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bg"
        "bi"
        "br"
        "ch"
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
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "kj"
        "kum"
        "kwm"
        "lb"
        "lg"
        "li"
        "lij"
        "mfe"
        "mg"
        "mhr"
        "mjw"
        "ms"
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
        "zh-cn"
        "zh-sg"
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
        "kai"
      ];

      vendor = "huozicool";
    };
  };
}
