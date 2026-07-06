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

  version = "1.3.0";

  src = fetchurl {
    hash = "sha256-dkScZxup9+VlGLPbWBDFAzo66f7zhqbItuteFVkaU+c=";
    url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/wangfonts/wangfonts-${version}.tar.gz";
  };

  meta = {
    description = "HanWang GSolid Chinese display typeface";
    homepage = "https://code.google.com/archive/p/wangfonts/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides the HanWang GSolid family from Hann-Tzong Wang, including a
      Traditional Chinese TrueType display font.
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

  pname = "hanwang-gsolid";

  sourceRoot = "wangfonts";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/hanwang \
      wtg-06cut1x.ttf

    runHook postInstall
  '';
}
