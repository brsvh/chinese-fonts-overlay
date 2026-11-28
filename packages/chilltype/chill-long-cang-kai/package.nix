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

  pname = "chill-long-cang-kai";
  version = "3.520";

  src = fetchurl {
    hash = "sha256-K9MhqHeZLFdHee70oAKfyUMR6G9qV/RgZfiZpapehcg=";
    url = "https://github.com/Warren2060/ChillCalligraphy/releases/download/LongCangv3.52/ChillLongCangKai_v${version}.zip";
  };

  meta = {
    description = "Chill Long Cang Kai calligraphic Chinese regular-script fonts";

    homepage = [
      "https://github.com/Warren2060/ChillCalligraphy"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Long Cang Kai from the ChillType ChillCalligraphy
      project, an expanded multi-weight calligraphic Chinese family derived
      from Long Cang. Includes Regular, Medium, Bold, and ExtraBold OpenType
      weights.
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
    find . -type f -name 'LICENSE.txt' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 {} "$docDir/LICENSE.txt" \;

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉龙藏楷书";

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
