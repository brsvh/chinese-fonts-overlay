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

  version = "0-unstable-2016-08-15";

  src = fetchurl {
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-/GDK/Gff6VhMxLKuugXOa515nsrbJVLydQe8hDdRHGM=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZXH1K.TTF";
  };

  meta = {
    description = "FZXiHeiI font distributed by FounderType";
    homepage = "https://www.foundertype.com";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZXiHeiI font.

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

  pname = "foundertype-fzxiheiyi";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZXH1K.TTF
    ln -s FZXH1K.TTF $fontDir/FZXH1K.ttf

    runHook postInstall
  '';
}
