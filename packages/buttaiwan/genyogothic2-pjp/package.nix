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
    hash = "sha256-GRNvRHvVUb6dNmng32ncc6qi3B2gWNPcSG0OW8S11+A=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenYoGothic2PJP-otf.zip";
  };

  meta = {
    description = "GenYoGothic2 PJP Japanese proportional Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoGothic2 PJP, the Japanese proportional Gothic
      variant of ButTaiwan's GenYoGothic2 Source Han Sans derivative,
      in ExtraLight, Light, Regular, Normal, Medium, Bold, and Heavy
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

  pname = "buttaiwan-genyogothic2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoGothic2PJP-EL.otf \
      GenYoGothic2PJP-L.otf \
      GenYoGothic2PJP-R.otf \
      GenYoGothic2PJP-N.otf \
      GenYoGothic2PJP-M.otf \
      GenYoGothic2PJP-B.otf \
      GenYoGothic2PJP-H.otf

    runHook postInstall
  '';
}
