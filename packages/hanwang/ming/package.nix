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
    description = "HanWang Ming Traditional Chinese typeface family";
    homepage = "https://code.google.com/archive/p/wangfonts/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides the HanWang Ming family from Hann-Tzong Wang, including
      light, medium, bold, heavy, black, Bopomofo annotated, and
      pronunciation variant TrueType fonts.
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

  pname = "hanwang-ming";

  sourceRoot = "wangfonts";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/hanwang \
      wp010-05.ttf \
      wp110-05.ttf \
      wp210-05.ttf \
      wp310-05.ttf \
      wt001.ttf \
      wt002.ttf \
      wt003.ttf \
      wt004.ttf \
      wt005.ttf

    runHook postInstall
  '';
}
