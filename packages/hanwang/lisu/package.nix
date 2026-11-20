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
    description = "HanWang LiSu Chinese typeface";
    homepage = "https://code.google.com/archive/p/wangfonts/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides the HanWang LiSu family from Hann-Tzong Wang, including a
      Traditional Chinese TrueType font.
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

  pname = "hanwang-lisu";

  sourceRoot = "wangfonts";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/hanwang \
      wt021.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "王漢宗隸書系列";

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
            文鼎科技与王漢宗字型存在纠纷，应当避免商业使用 hanwangPackages.lisu 中的如下字体：

            - HanWangLiSuMedium，王漢宗中隸書繁，wt021.ttf
          '';
        }
      ];

      styles = [
        "li"
      ];

      vendor = "hanwang";
    };
  };
}
