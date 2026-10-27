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

  pname = "lingdong-qiji";
  version = "0.0.4";

  regularSrc = fetchurl {
    hash = "sha256-LuMHONN7ECv6kOVs0E/eJiDM7wErRDkLd7BwPPmVz1s=";
    url = "https://github.com/LingDong-/qiji-font/releases/download/${version}/qiji.ttf";
  };

  fallbackSrc = fetchurl {
    hash = "sha256-AcHk+rHpKyfmGlSt/b9AskLT5wylNTOe8us6Ar1v16Q=";
    url = "https://github.com/LingDong-/qiji-font/releases/download/${version}/qiji-fallback.ttf";
  };

  comboSrc = fetchurl {
    hash = "sha256-+EIpGwOenFrmnt/pJO2+KLPPupG8rJV5G/H7wR2zMM8=";
    url = "https://github.com/LingDong-/qiji-font/releases/download/${version}/qiji-combo.ttf";
  };

  meta = {
    description = "Qiji Chinese woodblock printing fonts";
    homepage = "https://github.com/LingDong-/qiji-font";
    license = licenses.ofl;

    longDescription = ''
      Provides Qiji, a Ming-style Chinese font extracted from historical
      woodblock-printed books. The package includes the original glyphs,
      a fallback font derived from Source Han Serif, and the combined
      font, so applications can choose between the historical forms and
      the expanded character set.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    version
    ;

  dontUnpack = true;

  srcs = [
    regularSrc
    fallbackSrc
    comboSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lingdong
    install -Dm444 ${regularSrc} $fontDir/qiji.ttf
    install -Dm444 ${fallbackSrc} $fontDir/qiji-fallback.ttf
    install -Dm444 ${comboSrc} $fontDir/qiji-combo.ttf

    runHook postInstall
  '';
}
