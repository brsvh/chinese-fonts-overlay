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

  version = "1.0";

  src = fetchurl {
    hash = "sha256-CMu/TMQCXsOLu0m9IV6D7u/Gien453O+DHJGASVaU9A=";
    url = "https://github.com/justfont/TypeJam/releases/download/${version}/type-jam.otf";
  };

  meta = {
    description = "Type Jam crowdsourced handwriting font";
    homepage = "https://typejam.justfont.com/";
    license = licenses.ofl;

    longDescription = ''
      Provides Type Jam, also named 草率手寫體, a crowdsourced handwriting
      font created through a relay handwriting project by audiences of the
      2026 Taipei Art Book Fair. Upstream reports version 1.0 with 1,513
      included characters and releases it under the SIL Open Font License
      1.1.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "justfont-type-jam";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/justfont
    install -Dm444 $src $fontDir/type-jam.otf

    runHook postInstall
  '';
}
