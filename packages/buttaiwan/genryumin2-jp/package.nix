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
    hash = "sha256-IEBx3zqpVHgT496ztfxlpFnb5qbKP4zbUjwZCZ7WsbQ=";
    url = "https://github.com/ButTaiwan/genryu-font/releases/download/v${version}/GenRyuMin2JP-otf.zip";
  };

  meta = {
    description = "GenRyuMin2 JP Japanese text Mincho font family";
    homepage = "https://github.com/ButTaiwan/genryu-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenRyuMin2 JP, the Japanese text variant of
      ButTaiwan's GenRyuMin2 Source Han Serif derivative, in
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

  pname = "buttaiwan-genryumin2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenRyuMin2JP-EL.otf \
      GenRyuMin2JP-L.otf \
      GenRyuMin2JP-R.otf \
      GenRyuMin2JP-M.otf \
      GenRyuMin2JP-SB.otf \
      GenRyuMin2JP-B.otf \
      GenRyuMin2JP-H.otf

    runHook postInstall
  '';
}
