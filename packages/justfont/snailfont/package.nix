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

  pomaceaSrc = fetchurl {
    hash = "sha256-4kCTYTLyEQ6m+v5+9Clq9CAni7cxMbWcws3rwVk60Mo=";
    url = "https://github.com/justfont/Snailfont/releases/download/v${version}/snailfont-pomacea.otf";
  };

  sinotaiaSrc = fetchurl {
    hash = "sha256-m6ZJFYUCszbwKksCMArPjzmRA1Ofznzk6Kc80PrSuoA=";
    url = "https://github.com/justfont/Snailfont/releases/download/v${version}/snailfont-sinotaia.otf";
  };

  meta = {
    description = "Snail Font Bopomofo and Latin display fonts";
    homepage = "https://justfont.com/justforfun/snail-font";
    license = licenses.justfont-snailfont-license;

    longDescription = ''
      Provides Snail Font Pomacea and Snail Font Sinotaia, two Bopomofo
      and Latin display font styles from justfont and Tain Bun Sia.

      The Tain Bun Sia and justfont Snail Font license permits use,
      including most commercial use, without payment or prior notice. It
      prohibits direct sale of the fonts, release or sale as copybooks,
      stickers, or similar templates, and unauthorized modification,
      reproduction, or sale.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    version
    ;

  pname = "justfont-snailfont";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/justfont
    install -Dm444 ${pomaceaSrc} $fontDir/snailfont-pomacea.otf
    install -Dm444 ${sinotaiaSrc} $fontDir/snailfont-sinotaia.otf

    runHook postInstall
  '';
}
