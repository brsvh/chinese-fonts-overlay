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
    hash = "sha256-sYG8XeVy649byVjFVUF4mh7eCeqicRDqiMZJ5nrdo8s=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenYoMin2PJP-otf.zip";
  };

  meta = {
    description = "GenYoMin2 PJP Japanese proportional Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoMin2 PJP, the Japanese proportional variant of
      ButTaiwan's GenYoMin2 Source Han Serif derivative, in ExtraLight,
      Light, Regular, Medium, SemiBold, Bold, and Heavy weights.
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

  pname = "buttaiwan-genyomin2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoMin2PJP-EL.otf \
      GenYoMin2PJP-L.otf \
      GenYoMin2PJP-R.otf \
      GenYoMin2PJP-M.otf \
      GenYoMin2PJP-SB.otf \
      GenYoMin2PJP-B.otf \
      GenYoMin2PJP-H.otf

    runHook postInstall
  '';
}
