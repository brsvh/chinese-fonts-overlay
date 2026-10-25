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

  pname = "lxgw-marker-gothic";
  version = "1.004";

  src = fetchurl {
    hash = "sha256-SjDIIgBmTVNm7Y74Iu4gha0Wx2eGI5a5a4kk/ZQpeqY=";
    url = "https://github.com/lxgw/LxgwMarkerGothic/releases/download/v${version}/LxgwMarkerGothic-v${version}.zip";
  };

  meta = {
    description = "LXGW Marker Gothic Chinese handwriting font";
    homepage = "https://github.com/lxgw/LxgwMarkerGothic";
    license = licenses.ofl;

    longDescription = ''
      Provides LXGW Marker Gothic, a Chinese font derived from Tanugo
      with a marker-pen handwriting style for comics, advertising, and
      other display uses.
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

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 fonts/ttf/LXGWMarkerGothic-Regular.ttf $fontDir/LXGWMarkerGothic-Regular.ttf
    install -Dm444 OFL.txt $docDir/OFL.txt

    runHook postInstall
  '';
}
