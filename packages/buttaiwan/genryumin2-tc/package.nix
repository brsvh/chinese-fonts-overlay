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
    hash = "sha256-c5D9VAEDKKd+tbS/jfW5LZt9diIItimVVcspK3j2xvE=";
    url = "https://github.com/ButTaiwan/genryu-font/releases/download/v${version}/GenRyuMin2TC-otf.zip";
  };

  meta = {
    description = "GenRyuMin2 TC Traditional Chinese Mincho font family";
    homepage = "https://github.com/ButTaiwan/genryu-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenRyuMin2 TC, the Traditional Chinese print Mincho
      variant of ButTaiwan's GenRyuMin2 Source Han Serif derivative,
      in ExtraLight, Light, Regular, Medium, SemiBold, Bold, and
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

  pname = "buttaiwan-genryumin2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenRyuMin2TC-EL.otf \
      GenRyuMin2TC-L.otf \
      GenRyuMin2TC-R.otf \
      GenRyuMin2TC-M.otf \
      GenRyuMin2TC-SB.otf \
      GenRyuMin2TC-B.otf \
      GenRyuMin2TC-H.otf

    runHook postInstall
  '';
}
