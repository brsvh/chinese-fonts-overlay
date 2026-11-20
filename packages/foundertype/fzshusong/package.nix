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

    hash = "sha256-AP2/tDOq9MAN0Ct5MZu/6U/8o5nbob6eZFXku2UOAnM=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZSSK.TTF";
  };

  meta = {
    description = "FZShuSong font distributed by FounderType";
    homepage = "https://www.foundertype.com/index.php/FontInfo/index/id/151";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZShuSong font.

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

  pname = "foundertype-fzshusong";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZSSK.TTF
    ln -s FZSSK.TTF $fontDir/FZSSK.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "方正书宋";

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
        "serif"
        "song"
      ];

      vendor = "foundertype";
    };
  };
}
