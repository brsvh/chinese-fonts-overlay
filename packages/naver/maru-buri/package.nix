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

  pname = "naver-maru-buri";
  version = "1.000";

  src = fetchurl {
    hash = "sha256-cxNujd+DwO972Afv7sBjk9bXZ4SH1TZy3/nsk/cdG9A=";
    url = "https://hangeul.naver.com/hangeul_static/webfont/zips/maruburi.zip";
  };

  meta = {
    description = "Maru Buri Korean serif font family";
    homepage = "https://hangeul.naver.com/font";
    license = licenses.ofl;

    longDescription = ''
      Provides Maru Buri, a Korean serif family from NAVER and the NAVER
      Cultural Foundation, designed by AG Typography Institute for reading
      on digital screens. Includes the ExtraLight, Light, Regular, SemiBold,
      and Bold weights in TrueType format, with Hangul syllables and Latin
      characters.
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
    src
    version
    ;

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack

    unzip -j "$src" '*/MaruBuriTTF.zip'
    unzip MaruBuriTTF.zip

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/naver MaruBuri-*.ttf

    runHook postInstall
  '';
}
