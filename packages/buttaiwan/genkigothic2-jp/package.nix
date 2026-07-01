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
    hash = "sha256-Qvb/642DAXSd4Y/1bIW6VT8NLdp/1CZg2OOAlAnNwS8=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenKiGothic2JP-otf.zip";
  };

  meta = {
    description = "GenKiGothic2 JP Japanese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiGothic2 JP, the Japanese Gothic variant of
      ButTaiwan's GenKiGothic2 Source Han Sans derivative, in
      ExtraLight, Light, Regular, Medium, Bold, and Heavy weights.
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

  pname = "buttaiwan-genkigothic2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiGothic2JP-EL.otf \
      GenKiGothic2JP-L.otf \
      GenKiGothic2JP-R.otf \
      GenKiGothic2JP-M.otf \
      GenKiGothic2JP-B.otf \
      GenKiGothic2JP-H.otf

    runHook postInstall
  '';
}
