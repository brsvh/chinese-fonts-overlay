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

  pname = "cwtex-q-yuan";
  version = "0.42";

  fullSrc = fetchurl {
    hash = "sha256-DDy7oh0A9S35EEmZQ0uVm8a2NAItaFUvLjyFN5fbO9A=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQYuan-Medium.ttf";
  };

  zhSrc = fetchurl {
    hash = "sha256-aj1Sd4JJ2B7Ptgem7wApjV3SEFz5r1hAYOl6cZt/bRc=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQYuanZH-Medium.ttf";
  };

  meta = {
    description = "cwTeX Q Yuan Traditional Chinese fonts";
    homepage = "https://github.com/l10n-tw/cwtex-q-fonts";
    license = with licenses; [
      gpl2Plus
      ofl
    ];

    longDescription = ''
      Provides cwTeX Q Yuan Medium and its ZH variant for Traditional
      Chinese text. The full version includes additional non-Chinese glyphs;
      the ZH version contains Chinese characters and punctuation.

      The full version uses GPL 2.0 or later with a document embedding
      exception. The ZH version uses the SIL Open Font License 1.1.
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
    fullSrc
    zhSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/cwtex
    install -Dm444 ${fullSrc} $fontDir/cwTeXQYuan-Medium.ttf
    install -Dm444 ${zhSrc} $fontDir/cwTeXQYuanZH-Medium.ttf

    runHook postInstall
  '';
}
