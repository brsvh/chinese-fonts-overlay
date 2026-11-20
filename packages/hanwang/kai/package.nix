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

  version = "1.3.0";

  src = fetchurl {
    hash = "sha256-dkScZxup9+VlGLPbWBDFAzo66f7zhqbItuteFVkaU+c=";
    url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/wangfonts/wangfonts-${version}.tar.gz";
  };

  meta = {
    description = "HanWang Kai Chinese typeface family";
    homepage = "https://code.google.com/archive/p/wangfonts/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides the HanWang Kai family from Hann-Tzong Wang, including a
      Simplified Chinese bold TrueType font and Traditional Chinese
      Bopomofo annotated and pronunciation variant TrueType fonts.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "hanwang-kai";

  sourceRoot = "wangfonts";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/hanwang \
      wts11.ttf \
      wp010-08.ttf \
      wp110-08.ttf \
      wp210-08.ttf \
      wp310-08.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "王漢宗楷體系列";

      languages = [
        "bem"
        "cmn"
        "fj"
        "hak"
        "ho"
        "ia"
        "io"
        "kj"
        "kwm"
        "lzh"
        "ms"
        "ng"
        "nr"
        "om"
        "rn"
        "rw"
        "sn"
        "ss"
        "st"
        "sw"
        "ts"
        "uz"
        "xh"
        "za"
        "zh-tw"
        "zu"
      ];

      licenseCost = "free";

      notices = [
        {
          level = "caution";

          text = ''
            文鼎科技与王漢宗字型存在纠纷，应当避免商业使用 hanwangPackages.kai 中的如下字体：

            - HanWang KaiBold-Gb5，王漢宗粗楷體簡 / 王汉宗粗楷体简，wts11.ttf
          '';
        }
      ];

      styles = [
        "kai"
      ];

      vendor = "hanwang";
    };
  };
}
