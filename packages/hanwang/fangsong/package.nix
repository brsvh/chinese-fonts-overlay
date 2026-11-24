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
    description = "HanWang FangSong Chinese typeface family";
    homepage = "https://code.google.com/archive/p/wangfonts/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides the HanWang FangSong family from Hann-Tzong Wang, including
      Traditional and Simplified Chinese TrueType fonts.
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

  pname = "hanwang-fangsong";

  sourceRoot = "wangfonts";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/hanwang \
      wt024.ttf \
      wts47.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "王漢宗仿宋系列";

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
            文鼎科技与王漢宗字型存在纠纷，应当避免商业使用 hanwangPackages.fangsong 中的如下字体：

            - HanWangFangSongMedium，王漢宗中仿宋繁，wt024.ttf
            - HanWang FangSongMedium-Gb5，王漢宗中仿宋簡 / 王汉宗中仿宋简，wts47.ttf
          '';
        }
      ];

      styles = [
        "fangsong"
        "serif"
      ];

      vendor = "hanwang";
    };
  };
}
