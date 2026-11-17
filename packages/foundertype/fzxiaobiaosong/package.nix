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

    hash = "sha256-puTh7oh4uCS062bcWOJe0lWZLvOskBJkuERKW8WjACk=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZXBSK.TTF";
  };

  meta = {
    description = "FZXiaoBiaoSong font distributed by FounderType";
    homepage = "https://www.foundertype.com";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZXiaoBiaoSong font.

      Obtain the FounderType authorization appropriate to the intended
      use. Free trials offered to registered professional designers
      do not grant general personal or commercial usage rights.
      Do not redistribute font files or publish them through a binary
      cache without permission.
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

  pname = "foundertype-fzxiaobiaosong";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZXBSK.TTF
    ln -s FZXBSK.TTF $fontDir/FZXBSK.ttf

    runHook postInstall
  '';
}
