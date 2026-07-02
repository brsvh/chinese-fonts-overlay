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
    hash = "sha256-k4b+4cJ0Wy2PmlBJ6eyYXLKetVOi8IRjcZO0he3Fo8o=";
    url = "https://github.com/ButTaiwan/genwan-font/releases/download/v${version}/GenWanMin2TC-otf.zip";
  };

  meta = {
    description = "GenWanMin2 TC Traditional Chinese Mincho font family";
    homepage = "https://github.com/ButTaiwan/genwan-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenWanMin2 TC, the Traditional Chinese print Mincho
      variant of ButTaiwan's GenWanMin2 Source Han Serif derivative,
      in ExtraLight, Light, Regular, Medium, and SemiBold weights.
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

  pname = "buttaiwan-genwanmin2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenWanMin2TC-EL.otf \
      GenWanMin2TC-L.otf \
      GenWanMin2TC-R.otf \
      GenWanMin2TC-M.otf \
      GenWanMin2TC-SB.otf

    runHook postInstall
  '';
}
