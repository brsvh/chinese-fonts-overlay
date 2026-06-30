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

  version = "0-unstable-2016-08-17";

  src = fetchurl {
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-TF6fpWiBNZJeI4I751DkbKQTiFRQt8d6Lw4N3iZvciU=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZY4K.TTF";
  };

  meta = {
    description = "FZCuYuan font distributed by FounderType";
    homepage = "https://www.foundertype.com";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZCuYuan font.

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

  pname = "foundertype-fzcuyuan";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZY4K.TTF
    ln -s FZY4K.TTF $fontDir/FZY4K.ttf

    runHook postInstall
  '';
}
