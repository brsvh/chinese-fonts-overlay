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

  version = "2.100";

  src = fetchurl {
    hash = "sha256-N9Z8LDK4B62a9COnI+fLGfUT7PG9kfNeKoesIfngFrc=";
    url = "https://github.com/ButTaiwan/genseki-font/releases/download/v${version}/GenSekiGothic2TC-otf.zip";
  };

  meta = {
    description = "GenSekiGothic2 TC Traditional Chinese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genseki-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSekiGothic2 TC, the Traditional Chinese print-style
      Gothic variant of ButTaiwan's GenSekiGothic2 Source Han Sans
      derivative, in Light, Regular, Medium, Bold, and Heavy weights.
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

  pname = "buttaiwan-gensekigothic2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSekiGothic2TC-L.otf \
      GenSekiGothic2TC-R.otf \
      GenSekiGothic2TC-M.otf \
      GenSekiGothic2TC-B.otf \
      GenSekiGothic2TC-H.otf

    runHook postInstall
  '';
}
