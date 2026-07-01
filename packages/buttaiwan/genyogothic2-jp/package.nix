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
    hash = "sha256-5RgLfCxG7FcY4QFeb/Qmh8Qr6YwiZd9zwbn4GVmfb0E=";
    url = "https://github.com/ButTaiwan/genyog-font/releases/download/v${version}/GenYoGothic2JP-otf.zip";
  };

  meta = {
    description = "GenYoGothic2 JP Japanese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genyog-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoGothic2 JP, the Japanese Gothic variant of
      ButTaiwan's GenYoGothic2 Source Han Sans derivative, in
      ExtraLight, Light, Regular, Normal, Medium, Bold, and Heavy
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

  pname = "buttaiwan-genyogothic2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoGothic2JP-EL.otf \
      GenYoGothic2JP-L.otf \
      GenYoGothic2JP-R.otf \
      GenYoGothic2JP-N.otf \
      GenYoGothic2JP-M.otf \
      GenYoGothic2JP-B.otf \
      GenYoGothic2JP-H.otf

    runHook postInstall
  '';
}
