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
    hash = "sha256-XN+wSpQo+28+2/OFNovJ6bWeqSeSmR4hAd6Ka3UO9y4=";
    url = "https://github.com/ButTaiwan/gensen-font/releases/download/v${version}/GenSenRounded2PJP-otf.zip";
  };

  meta = {
    description = "GenSenRounded2 PJP Japanese proportional rounded Gothic font family";
    homepage = "https://github.com/ButTaiwan/gensen-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSenRounded2 PJP, the Japanese proportional rounded
      Gothic variant of ButTaiwan's GenSenRounded2 Source Han Sans
      derivative, in ExtraLight, Light, Regular, Medium, Bold, and
      Heavy weights.
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

  pname = "buttaiwan-gensenrounded2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSenRounded2PJP-EL.otf \
      GenSenRounded2PJP-L.otf \
      GenSenRounded2PJP-R.otf \
      GenSenRounded2PJP-M.otf \
      GenSenRounded2PJP-B.otf \
      GenSenRounded2PJP-H.otf

    runHook postInstall
  '';
}
