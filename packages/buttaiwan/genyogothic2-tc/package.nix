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
    hash = "sha256-6HpjhUpPN44DaEN3xtjUkQmXNyMxeZYb3nDNDYOw6Ek=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenYoGothic2TC-otf.zip";
  };

  meta = {
    description = "GenYoGothic2 TC Traditional Chinese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoGothic2 TC, the Traditional Chinese print-style
      Gothic variant of ButTaiwan's GenYoGothic2 Source Han Sans
      derivative, in ExtraLight, Light, Regular, Normal, Medium,
      Bold, and Heavy weights.
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

  pname = "buttaiwan-genyogothic2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoGothic2TC-EL.otf \
      GenYoGothic2TC-L.otf \
      GenYoGothic2TC-R.otf \
      GenYoGothic2TC-N.otf \
      GenYoGothic2TC-M.otf \
      GenYoGothic2TC-B.otf \
      GenYoGothic2TC-H.otf

    runHook postInstall
  '';
}
