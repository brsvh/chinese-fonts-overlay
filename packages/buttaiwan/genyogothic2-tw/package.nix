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
    hash = "sha256-YWvibjRIsTlrNCUz0EbYuw1bGAHYC1qO6IKBG9xiXXw=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenYoGothic2TW-otf.zip";
  };

  meta = {
    description = "GenYoGothic2 TW Traditional Chinese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoGothic2 TW, the Traditional Chinese modern-use
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

  pname = "buttaiwan-genyogothic2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoGothic2TW-EL.otf \
      GenYoGothic2TW-L.otf \
      GenYoGothic2TW-R.otf \
      GenYoGothic2TW-N.otf \
      GenYoGothic2TW-M.otf \
      GenYoGothic2TW-B.otf \
      GenYoGothic2TW-H.otf

    runHook postInstall
  '';
}
