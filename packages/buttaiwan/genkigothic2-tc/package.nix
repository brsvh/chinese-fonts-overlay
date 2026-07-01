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
    hash = "sha256-wbeiMrMjWOZt998upv2bJtAsB2QGUUWT/dB+pt7POJI=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenKiGothic2TC-otf.zip";
  };

  meta = {
    description = "GenKiGothic2 TC Traditional Chinese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiGothic2 TC, the Traditional Chinese print-style
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

  pname = "buttaiwan-genkigothic2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiGothic2TC-EL.otf \
      GenKiGothic2TC-L.otf \
      GenKiGothic2TC-R.otf \
      GenKiGothic2TC-M.otf \
      GenKiGothic2TC-B.otf \
      GenKiGothic2TC-H.otf

    runHook postInstall
  '';
}
