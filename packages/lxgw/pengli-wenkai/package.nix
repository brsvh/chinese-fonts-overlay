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

  pname = "lxgw-pengli-wenkai";
  version = "1.034";

  src = fetchurl {
    hash = "sha256-6CyUaRZSb20wuPzNE3wnaLAqA4E7Nn1Mh7iOwTV1DRo=";
    url = "https://github.com/lxgw/Pengli/releases/download/v${version}/PengliWenKai-Regular.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-PKX9YJVrhoXHN2ivG17dgctZZ/EuuPRAjLjptn1llng=";
    url = "https://raw.githubusercontent.com/lxgw/Pengli/v${version}/OFL.txt";
  };

  meta = {
    description = "Pengli WenKai Traditional Chinese handwriting font";
    homepage = "https://github.com/lxgw/Pengli";
    license = licenses.ofl;

    longDescription = ''
      Provides Pengli WenKai, a Traditional Chinese handwriting font
      derived from LXGW WenKai GB and adjusted for the glyph conventions
      used in printing classical Chinese texts.
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

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${src} $fontDir/PengliWenKai-Regular.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';
}
