{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  pname = "tanuki-permanent-marker";
  version = "1.22";

  src = fetchurl {
    hash = "sha256-Z/nvaLBDwDbcjGTMcMJmuVR4U5ePzyCQUKgiHJF2bh8=";
    url = "https://tanukifont.com/download/TanukiMagic_1_22.zip";
  };

  meta = {
    description = "Tanuki Permanent Marker Japanese handwriting font";
    homepage = "https://tanukifont.com/tanuki-permanent-marker";
    license =
      licenses.tanuki-permanent-marker-license;

    longDescription = ''
      Provides Tanuki Permanent Marker, a Japanese handwriting font that
      reproduces rounded strokes drawn with a felt-tip marker. It includes
      hiragana, katakana, Latin characters, numerals, and JIS level 1 and
      level 2 kanji in one regular style.

      Tanukizamurai permits personal and commercial use, including embedding
      in documents and applications. Selling the font or fonts derived from
      it requires permission. General standalone redistribution is not
      explicitly granted.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    src
    version
    ;

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tanuki
    install -Dm444 TanukiMagic.ttf $fontDir/TanukiMagic.ttf

    runHook postInstall
  '';
}
