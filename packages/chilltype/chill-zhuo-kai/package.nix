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

  pname = "chill-zhuo-kai";
  version = "1.300";

  src = fetchurl {
    hash = "sha256-K5mHyKv06x6aI0rhbdTLiQ9zqXOv58wwDSM/y8Axy2M=";
    url = "https://github.com/Warren2060/ChillZhuoKai/releases/download/v${version}/ChillZhuoKai_R.otf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-CcC9TWARb4r+dVcj83jWkzf6NX5hq9EGMkVa9h4kMa8=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillZhuoKai/b4a9b82cbe9a881d43d01184f2625a39dd0e729b/LICENSE";
  };

  meta = {
    description = "Chill Zhuo Kai brush-calligraphy Chinese regular-script font";

    homepage = [
      "https://github.com/Warren2060/ChillZhuoKai"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Zhuo Kai from ChillType, a brush-style Chinese
      regular-script OpenType font extending Yuji Syuku with generated
      Simplified Chinese glyphs and typography refinements.
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

    fontDir=$out/share/fonts/opentype/chilltype
    docDir=$out/share/doc/${pname}
    install -Dm444 "$src" "$fontDir/ChillZhuoKai_R.otf"
    install -Dm444 ${licenseSrc} "$docDir/LICENSE"

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉拙楷体";

      languages = [
        "bem"
        "bg"
        "fj"
        "ho"
        "ia"
        "io"
        "kj"
        "kum"
        "kwm"
        "mhr"
        "ms"
        "ng"
        "nr"
        "om"
        "os"
        "rn"
        "ru"
        "rw"
        "sel"
        "sm"
        "sn"
        "ss"
        "st"
        "sw"
        "to"
        "ts"
        "uz"
        "xh"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "cal"
        "kai"
      ];

      vendor = "chilltype";
    };
  };
}
