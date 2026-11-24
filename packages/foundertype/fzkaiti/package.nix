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

  version = "0-unstable-2024-05-22";

  src = fetchurl {
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-ZSfxpTQU2dHc22T38mzEUe96ssV6KisaBuUlXpfy2JQ=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZKTK.TTF";
  };

  meta = {
    description = "FZKaiTi font distributed by FounderType";
    homepage = "https://www.foundertype.com/index.php/FontInfo/index/id/137";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZKaiTi font.

      Obtain the FounderType Font Library Commercial Release
      Authorization Statement before use. After obtaining it, do not
      redistribute the font files or publish them through a binary
      cache.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "foundertype-fzkaiti";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZKTK.TTF
    ln -s FZKTK.TTF $fontDir/FZKTK.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "方正楷体";

      languages = [
        "agr"
        "bem"
        "bg"
        "cmn"
        "fj"
        "hak"
        "ho"
        "ia"
        "io"
        "kj"
        "kum"
        "kwm"
        "lzh"
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

      licenseCost = "gratisCommercialUse";

      styles = [
        "kai"
      ];

      vendor = "foundertype";
    };
  };
}
