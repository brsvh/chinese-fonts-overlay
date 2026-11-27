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

  pname = "huozicool-kinghwa-oldsong-i";
  version = "3.000";

  src = fetchurl {
    hash = "sha256-9tlI//+9rqweVf2FtzLSXXiok47gLVOWGXTZszqGc1U=";
    name = "KingHwaOldSong-I.Ming.ttf";
    url = "https://huozi.cool/fonts/%E4%BA%AC%E8%8F%AF%E8%80%81%E5%AE%8B%E4%BD%93-I.%E6%AA%A2%E6%A0%A1%E8%A1%A8%E6%8E%A8%E8%96%A6%E5%BD%A2.ttf";
  };

  meta = {
    description = "KingHwa OldSong I.Ming recommended glyph edition from Huozicool";

    homepage = [
      "https://huozi.cool/"
      "https://huozi.cool/article/1780107524889.html"
    ];

    license =
      licenses.huozicool-kinghwa-oldsong-license;

    longDescription = ''
      Provides KingHwa OldSong I.Ming, the inherited printing glyph
      edition following I.Ming editorial recommendations of the 61-1
      letterpress serif font from TerryWang and Huozicool.

      The Huozicool KingHwa OldSong license permits free commercial use,
      embedding in software and electronic devices, and free
      redistribution. Modifying the font glyphs, distributing modified
      files, selling the font standalone for profit, and unlawful use
      are prohibited.
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
    install -Dm444 $src $fontDir/KingHwaOldSong-I.Ming.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "京華老宋体-I.";

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
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "warning";

          text = ''
            京華老宋体全系列免费商用，允许复制传播并嵌入电子产品或软件应用，但禁止修改字形或传播改版文件，不得单独出售字体盈利，且不得用于违法犯罪活动。
          '';

          url = "https://huozi.cool/article/1780107524889.html";
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
