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

  pname = "cwtex-q-kai";
  version = "0.42";

  fullSrc = fetchurl {
    hash = "sha256-eZSx7feRDFuMUG67fis+TVCPxOwKzAAlCa0agv2DhH8=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQKai-Medium.ttf";
  };

  zhSrc = fetchurl {
    hash = "sha256-YWQHqkQtTfgjwSrEXbAurrB8I5QYSywavgPB54+s9g0=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQKaiZH-Medium.ttf";
  };

  meta = {
    description = "cwTeX Q Kai Traditional Chinese fonts";
    homepage = "https://github.com/l10n-tw/cwtex-q-fonts";
    license = with licenses; [
      gpl2Plus
      ofl
    ];

    longDescription = ''
      Provides cwTeX Q Kai Medium and its ZH variant for Traditional
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
    install -Dm444 ${fullSrc} $fontDir/cwTeXQKai-Medium.ttf
    install -Dm444 ${zhSrc} $fontDir/cwTeXQKaiZH-Medium.ttf

    runHook postInstall
  '';
}
