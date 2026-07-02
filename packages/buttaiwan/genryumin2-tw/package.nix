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
    hash = "sha256-p7WlMayzBZenkC73S9T9a2BuxHwsCTJu7Lr1SHV5EkA=";
    url = "https://github.com/ButTaiwan/genryu-font/releases/download/v${version}/GenRyuMin2TW-otf.zip";
  };

  meta = {
    description = "GenRyuMin2 TW Traditional Chinese Mincho font family";
    homepage = "https://github.com/ButTaiwan/genryu-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenRyuMin2 TW, the Traditional Chinese modern Mincho
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

  pname = "buttaiwan-genryumin2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenRyuMin2TW-EL.otf \
      GenRyuMin2TW-L.otf \
      GenRyuMin2TW-R.otf \
      GenRyuMin2TW-M.otf \
      GenRyuMin2TW-SB.otf \
      GenRyuMin2TW-B.otf \
      GenRyuMin2TW-H.otf

    runHook postInstall
  '';
}
