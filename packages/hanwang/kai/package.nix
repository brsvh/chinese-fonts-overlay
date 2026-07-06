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
    description = "HanWang Kai Chinese typeface family";
    homepage = "https://code.google.com/archive/p/wangfonts/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides the HanWang Kai family from Hann-Tzong Wang, including a
      Simplified Chinese bold TrueType font and Traditional Chinese
      Bopomofo annotated and pronunciation variant TrueType fonts.
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

  pname = "hanwang-kai";

  sourceRoot = "wangfonts";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/hanwang \
      wts11.ttf \
      wp010-08.ttf \
      wp110-08.ttf \
      wp210-08.ttf \
      wp310-08.ttf

    runHook postInstall
  '';
}
