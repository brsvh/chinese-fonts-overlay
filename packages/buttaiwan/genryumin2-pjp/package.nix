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
    hash = "sha256-5ewsGqEmjqzfAdKP5hPqqE1nFHwnP5y2rZry2ojgLkA=";
    url = "https://github.com/ButTaiwan/genryu-font/releases/download/v${version}/GenRyuMin2PJP-otf.zip";
  };

  meta = {
    description = "GenRyuMin2 PJP Japanese proportional text Mincho font family";
    homepage = "https://github.com/ButTaiwan/genryu-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenRyuMin2 PJP, the Japanese proportional text variant
      of ButTaiwan's GenRyuMin2 Source Han Serif derivative, in
      ExtraLight, Light, Regular, Medium, SemiBold, Bold, and Heavy
      weights.
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

  pname = "buttaiwan-genryumin2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenRyuMin2PJP-EL.otf \
      GenRyuMin2PJP-L.otf \
      GenRyuMin2PJP-R.otf \
      GenRyuMin2PJP-M.otf \
      GenRyuMin2PJP-SB.otf \
      GenRyuMin2PJP-B.otf \
      GenRyuMin2PJP-H.otf

    runHook postInstall
  '';
}
