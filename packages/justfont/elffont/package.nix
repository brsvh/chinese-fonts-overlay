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

  fernSrc = fetchurl {
    hash = "sha256-qzheM4x2ST9yBJUIyaFD9puitSTyVaYxwI6JBieO51c=";
    url = "https://github.com/justfont/Elffont/releases/download/v${version}/elffont-fern.otf";
  };

  rockSrc = fetchurl {
    hash = "sha256-tMqf2C4eZ2/QDrAgMnS00pF9FvBBNZxQJNsnA9/B7bI=";
    url = "https://github.com/justfont/Elffont/releases/download/v${version}/elffont-rock.otf";
  };

  meta = {
    description = "Elffont Bopomofo display fonts";
    homepage = "https://ref.justfont.com/gRbXjtF";
    license = licenses.justfont-elffont-license;

    longDescription = ''
      Provides Elffont Fern and Elffont Rock, two Bopomofo display font
      styles from calligrapher Daphne and justfont. They are intended for
      Zhuyin text and use ornate forms inspired by fantasy writing styles.

      The Daphne and justfont Elffont license permits use, including
      commercial use, without payment or prior notice. It prohibits direct
      sale of the fonts, release or sale as copybooks or templates, and
      unauthorized modification, reproduction, or sale.
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

  pname = "justfont-elffont";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/justfont
    install -Dm444 ${fernSrc} $fontDir/elffont-fern.otf
    install -Dm444 ${rockSrc} $fontDir/elffont-rock.otf

    runHook postInstall
  '';
}
