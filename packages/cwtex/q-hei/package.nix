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

  pname = "cwtex-q-hei";
  version = "0.42";

  fullSrc = fetchurl {
    hash = "sha256-W0co6aFExG9AQ9/tkjb1/Jj7nqeRtikVXABCeM/xcjY=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQHei-Bold.ttf";
  };

  zhSrc = fetchurl {
    hash = "sha256-k3D1ICqxxDTqR3CvbFrOcKCRVWfEbDGyxlWHx501hpo=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQHeiZH-Bold.ttf";
  };

  meta = {
    description = "cwTeX Q Hei Traditional Chinese fonts";
    homepage = "https://github.com/l10n-tw/cwtex-q-fonts";
    license = with licenses; [
      gpl2Plus
      ofl
    ];

    longDescription = ''
      Provides cwTeX Q Hei Bold and its ZH variant for Traditional
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
    install -Dm444 ${fullSrc} $fontDir/cwTeXQHei-Bold.ttf
    install -Dm444 ${zhSrc} $fontDir/cwTeXQHeiZH-Bold.ttf

    runHook postInstall
  '';
}
