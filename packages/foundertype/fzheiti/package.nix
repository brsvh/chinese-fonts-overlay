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

    hash = "sha256-W+Y9vIZPBLAS+D21Oy4OpKLHAxHEpCzDPGIGrpzUfvA=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZHTK.TTF";
  };

  meta = {
    description = "FZHeiTi font distributed by FounderType";
    homepage = "https://www.foundertype.com";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZHeiTi font.

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

  pname = "foundertype-fzheiti";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZHTK.TTF
    ln -s FZHTK.TTF $fontDir/FZHTK.ttf

    runHook postInstall
  '';
}
