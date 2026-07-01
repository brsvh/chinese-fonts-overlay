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
    hash = "sha256-FM52pJQKOTgwGZzfyfqfH9oeXwyCJdv66AOBtRvgeBc=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenKiGothic2TW-otf.zip";
  };

  meta = {
    description = "GenKiGothic2 TW Traditional Chinese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiGothic2 TW, the Traditional Chinese modern-use
      Gothic variant of ButTaiwan's GenKiGothic2 Source Han Sans
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

  pname = "buttaiwan-genkigothic2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiGothic2TW-EL.otf \
      GenKiGothic2TW-L.otf \
      GenKiGothic2TW-R.otf \
      GenKiGothic2TW-M.otf \
      GenKiGothic2TW-B.otf \
      GenKiGothic2TW-H.otf

    runHook postInstall
  '';
}
