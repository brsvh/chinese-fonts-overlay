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
    hash = "sha256-BccJsoUS3T+793Wg5Eugn3h9DOPUUqQpcB2vAgLkB64=";
    url = "https://github.com/ButTaiwan/genseki-font/releases/download/v${version}/GenSekiGothic2JP-otf.zip";
  };

  meta = {
    description = "GenSekiGothic2 JP Japanese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genseki-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSekiGothic2 JP, the Japanese Gothic variant of
      ButTaiwan's GenSekiGothic2 Source Han Sans derivative, in
      Light, Regular, Medium, Bold, and Heavy weights.
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

  pname = "buttaiwan-gensekigothic2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSekiGothic2JP-L.otf \
      GenSekiGothic2JP-R.otf \
      GenSekiGothic2JP-M.otf \
      GenSekiGothic2JP-B.otf \
      GenSekiGothic2JP-H.otf

    runHook postInstall
  '';
}
