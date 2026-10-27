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

  pname = "cwtex-q-fangsong";
  version = "0.42";

  fullSrc = fetchurl {
    hash = "sha256-dA87jgWjNVb3JlxoQMALO8EBSPKKBdnSqiwSLlNH6dc=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQFangsong-Medium.ttf";
  };

  zhSrc = fetchurl {
    hash = "sha256-FP63ugRZqf+wYNqhI55z8F7Qu+fRT8ccZK6vz6gN9p0=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQFangsongZH-Medium.ttf";
  };

  meta = {
    description = "cwTeX Q Fangsong Traditional Chinese fonts";
    homepage = "https://github.com/l10n-tw/cwtex-q-fonts";
    license = with licenses; [
      gpl2Plus
      ofl
    ];

    longDescription = ''
      Provides cwTeX Q Fangsong Medium and its ZH variant for Traditional
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
    install -Dm444 ${fullSrc} $fontDir/cwTeXQFangsong-Medium.ttf
    install -Dm444 ${zhSrc} $fontDir/cwTeXQFangsongZH-Medium.ttf

    runHook postInstall
  '';
}
