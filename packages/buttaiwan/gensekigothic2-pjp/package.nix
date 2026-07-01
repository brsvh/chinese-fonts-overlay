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
    hash = "sha256-4sAQFCv4CVXqvjEtULjBPsT+OsepG1h19QFDw/KHtvo=";
    url = "https://github.com/ButTaiwan/genseki-font/releases/download/v${version}/GenSekiGothic2PJP-otf.zip";
  };

  meta = {
    description = "GenSekiGothic2 PJP Japanese proportional Gothic font family";
    homepage = "https://github.com/ButTaiwan/genseki-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSekiGothic2 PJP, the Japanese proportional Gothic
      variant of ButTaiwan's GenSekiGothic2 Source Han Sans
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

  pname = "buttaiwan-gensekigothic2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSekiGothic2PJP-L.otf \
      GenSekiGothic2PJP-R.otf \
      GenSekiGothic2PJP-M.otf \
      GenSekiGothic2PJP-B.otf \
      GenSekiGothic2PJP-H.otf

    runHook postInstall
  '';
}
