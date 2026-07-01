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

  version = "1.003";

  src = fetchurl {
    hash = "sha256-byt53g7gE/Jg/Ii0xmiWnjT9/oe32u7K7rWtWpfrmIM=";
    url = "https://github.com/justfont/Huninn/releases/download/v${version}/Huninn-Regular.ttf";
  };

  meta = {
    description = "Huninn Traditional Chinese rounded typeface";
    homepage = "https://github.com/justfont/Huninn";
    license = licenses.ofl;

    longDescription = ''
      Provides Huninn, a Traditional Chinese rounded typeface from
      justfont. Upstream describes it as designed for Taiwan, with
      commonly used Traditional Chinese characters, Bopomofo, and
      Taiwanese Hokkien phonetic symbols and characters.
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

  pname = "justfont-huninn";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/justfont
    install -Dm444 $src $fontDir/Huninn-Regular.ttf

    runHook postInstall
  '';
}
