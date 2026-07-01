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
    hash = "sha256-wlt354x4n9vzA21eSJJRxwXq9V/0N7XpedYtmAAlzac=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenKiMin2PJP-otf.zip";
  };

  meta = {
    description = "GenKiMin2 PJP Japanese proportional Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiMin2 PJP, the Japanese proportional variant of
      ButTaiwan's GenKiMin2 Source Han Serif derivative, in ExtraLight,
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

  pname = "buttaiwan-genkimin2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiMin2PJP-EL.otf \
      GenKiMin2PJP-L.otf \
      GenKiMin2PJP-R.otf \
      GenKiMin2PJP-M.otf \
      GenKiMin2PJP-SB.otf \
      GenKiMin2PJP-B.otf \
      GenKiMin2PJP-H.otf

    runHook postInstall
  '';
}
