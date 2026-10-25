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

  pname = "lxgw-xiaolai";
  version = "3.126";

  regularSrc = fetchurl {
    hash = "sha256-4vaNrw5yd3qM9YvIPeG5hjSyUeU33b/KJLCuUNGALaI=";
    url = "https://github.com/lxgw/kose-font/releases/download/v${version}/Xiaolai-Regular.ttf";
  };

  monoSrc = fetchurl {
    hash = "sha256-gCtljbSS4Crltln1tW19Tvj3dglRW9zIL0Yq6RKIjDM=";
    url = "https://github.com/lxgw/kose-font/releases/download/v${version}/XiaolaiMono-Regular.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-Dffgm+TCyFCki9i+uc1ks0Oq1JzV0/bPsq0uPSilbKQ=";
    url = "https://raw.githubusercontent.com/lxgw/kose-font/v${version}/OFL.txt";
  };

  meta = {
    description = "Xiaolai Chinese handwriting fonts";
    homepage = "https://github.com/lxgw/kose-font";
    license = licenses.ofl;

    longDescription = ''
      Provides Xiaolai and Xiaolai Mono, Chinese handwriting fonts
      derived from SetoFont with additional Simplified Chinese
      characters. The regular variant uses proportional Latin glyphs,
      while Mono provides a monospaced alternative.
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
    version
    ;

  dontUnpack = true;

  srcs = [
    regularSrc
    monoSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${regularSrc} $fontDir/Xiaolai-Regular.ttf
    install -Dm444 ${monoSrc} $fontDir/XiaolaiMono-Regular.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';
}
