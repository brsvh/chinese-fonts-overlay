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
    hash = "sha256-4mjinu1yqAL6rexAu5BFAU6eJDqVCbC92N1FAGdH4vY=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenKiGothic2PJP-otf.zip";
  };

  meta = {
    description = "GenKiGothic2 PJP Japanese proportional Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiGothic2 PJP, the Japanese proportional Gothic
      variant of ButTaiwan's GenKiGothic2 Source Han Sans derivative,
      in ExtraLight, Light, Regular, Medium, Bold, and Heavy weights.
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

  pname = "buttaiwan-genkigothic2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiGothic2PJP-EL.otf \
      GenKiGothic2PJP-L.otf \
      GenKiGothic2PJP-R.otf \
      GenKiGothic2PJP-M.otf \
      GenKiGothic2PJP-B.otf \
      GenKiGothic2PJP-H.otf

    runHook postInstall
  '';
}
