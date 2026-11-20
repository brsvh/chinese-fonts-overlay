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
    description = "HanWang Ming Traditional Chinese typeface family";
    homepage = "https://code.google.com/archive/p/wangfonts/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides the HanWang Ming family from Hann-Tzong Wang, including
      light, medium, bold, heavy, black, Bopomofo annotated, and
      pronunciation variant TrueType fonts.
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

  pname = "hanwang-ming";

  sourceRoot = "wangfonts";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/hanwang \
      wp010-05.ttf \
      wp110-05.ttf \
      wp210-05.ttf \
      wp310-05.ttf \
      wt001.ttf \
      wt002.ttf \
      wt003.ttf \
      wt004.ttf \
      wt005.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "王漢宗明體系列";

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
            文鼎科技与王漢宗字型存在纠纷，应当避免商业使用 hanwangPackages.ming 中的如下字体：

            - HanWangMingMedium，王漢宗中明體繁，wt002.ttf
            - HanWangMingMediumChuIn，王漢宗中明體注音，wp010-05.ttf
            - HanWangMingMediumPoIn1，王漢宗中明體破音一，wp110-05.ttf
            - HanWangMingMediumPoIn2，王漢宗中明體破音二，wp210-05.ttf
            - HanWangMingMediumPoIn3，王漢宗中明體破音三，wp310-05.ttf
            - HanWangMingBold，王漢宗粗明體繁，wt003.ttf
            - HanWangMingHeavy，王漢宗特明體繁，wt004.ttf
          '';
        }
      ];

      styles = [
        "serif"
        "song"
      ];

      vendor = "hanwang";
    };
  };
}
