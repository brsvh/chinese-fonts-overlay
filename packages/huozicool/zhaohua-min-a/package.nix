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

  pname = "huozicool-zhaohua-min-a";
  version = "1.001";

  src = fetchurl {
    hash = "sha256-eRsKq8/KBRf/wPnTm/oLenIJsiW51QYcZodgo6eefCQ=";
    name = "ZhaohuaMinA-Bold.ttf";
    url = "https://huozi.cool/newfonts/%C3%A6%C2%9C%C2%9D%C3%A8%C2%8F%C2%AF%C3%A6%C2%A8%C2%99%C3%A9%C2%A1%C2%8CA.ttf";
  };

  meta = {
    description = "Zhaohua Min A display serif font from Huozicool";

    homepage = [
      "https://huozi.cool/"
      "https://huozi.cool/article/1780107571976.html"
    ];

    license =
      licenses.huozicool-zhaohua-title-license;

    longDescription = ''
      Provides Zhaohua Min A, a bold letterpress-style Chinese display
      serif font from TerryWang and Huozicool modeled on Tsukiji No. 2
      Mincho metal type.

      The Huozicool Zhaohua Title font license permits free commercial
      use, embedding in software and electronic devices, free
      redistribution, and derivative modification. Selling the font
      standalone or bundled as assets for profit and unlawful use are
      prohibited, and the author disclaims liability for non-standard
      glyph forms.
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
    install -Dm444 $src $fontDir/ZhaohuaMinA-Bold.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "朝华标题 A";

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
        "cmn"
        "co"
        "cy"
        "da"
        "de"
        "el"
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
        "kum"
        "kwm"
        "lb"
        "li"
        "lij"
        "lzh"
        "mfe"
        "mg"
        "mhr"
        "mjw"
        "ms"
        "nan"
        "nb"
        "nds"
        "ng"
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
        "xh"
        "yap"
        "yue"
        "yuw"
        "za"
        "zh-cn"
        "zh-hk"
        "zh-mo"
        "zh-sg"
        "zu"
      ];

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "important";

          text = ''
            朝华标题系列免费商用，允许嵌入电子产品或软件应用、自由复制传播及修改衍生，但禁止以任何形式单独或打包作为素材、字体文件出售盈利，且不得用于违法犯罪活动。字体包含大量不符合现代各地规范的写法，请勿用于用字严谨场合或教育用途，作者不承担相关责任。
          '';

          url = "https://huozi.cool/article/1780107571976.html";
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
