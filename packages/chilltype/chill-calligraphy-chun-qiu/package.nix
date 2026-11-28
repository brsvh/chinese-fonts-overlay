{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  pname = "chill-calligraphy-chun-qiu";
  version = "1.650";

  src = fetchurl {
    hash = "sha256-h66xfvkVewN4NdfLeaYgUMS42wwfTwbkdtCzCUMo1+A=";
    url = "https://github.com/Warren2060/ChillCalligraphy/releases/download/ChunQiu_v${version}/ChillCalligraphyChunQiu_v${version}.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-jRd+0ZcllLu/9p0mKJUyCcIPxO02xANZGgICDUuMRAI=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillCalligraphy/a657f3cdd2f493692c5d38cf0ac40aa590478a73/LICENSE";
  };

  meta = {
    description = "Chill Calligraphy ChunQiu Chinese brush calligraphy fonts";

    homepage = [
      "https://github.com/Warren2060/ChillCalligraphy"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Calligraphy ChunQiu from ChillType, expanded Chinese
      calligraphy OpenType fonts derived from Slidefont Chunfeng Kai and
      Qiuhong Kai. Includes ChenFeng and QiuHong styles.
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

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/chilltype
    docDir=$out/share/doc/${pname}
    find . -type f -name '*.otf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    install -Dm444 ${licenseSrc} "$docDir/LICENSE"

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉书体·春秋";

      languages = [
        "bem"
        "fj"
        "ho"
        "ia"
        "io"
        "kj"
        "kwm"
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

  sourceRoot = ".";
}
