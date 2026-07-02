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
    hash = "sha256-vagmDF+9SCLD2h3RFhqBj18v/DAjyE4iYs4vslLkb38=";
    url = "https://github.com/ButTaiwan/genwan-font/releases/download/v${version}/GenWanMin2PJP-otf.zip";
  };

  meta = {
    description = "GenWanMin2 PJP Japanese proportional text Mincho font family";
    homepage = "https://github.com/ButTaiwan/genwan-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenWanMin2 PJP, the Japanese proportional text variant
      of ButTaiwan's GenWanMin2 Source Han Serif derivative, in
      ExtraLight, Light, Regular, Medium, and SemiBold weights.
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

  pname = "buttaiwan-genwanmin2-pjp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenWanMin2PJP-EL.otf \
      GenWanMin2PJP-L.otf \
      GenWanMin2PJP-R.otf \
      GenWanMin2PJP-M.otf \
      GenWanMin2PJP-SB.otf

    runHook postInstall
  '';
}
