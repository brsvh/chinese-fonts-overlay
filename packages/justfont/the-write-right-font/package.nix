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

  version = "2023.0401";

  src = fetchurl {
    hash = "sha256-cICcEJclnOWqr4JNGNyfUD1UJg91RosC3SG+1ED5MbA=";
    url = "https://github.com/justfont/The-Write-Right-Font/releases/download/${version}/the-write-right-font-${version}.ttf";
  };

  meta = {
    description = "The Write Right Font typo-correcting Traditional Chinese typeface";
    homepage = "https://github.com/justfont/The-Write-Right-Font";
    license = licenses.ofl;

    longDescription = ''
      Provides The Write Right Font, also named Jiu Shi Bu Cuo Zi (Ba),
      a Traditional Chinese typeface from justfont. It is based on
      Iansui and uses OpenType substitutions to correct selected common
      typos when supported by the application.
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

  pname = "justfont-the-write-right-font";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/justfont
    install -Dm444 $src $fontDir/the-write-right-font-${version}.ttf

    runHook postInstall
  '';
}
