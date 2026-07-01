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
    hash = "sha256-Rv+pGrfyGur6xRCzVe6dVGYy42ZXTtR/IcLdYU+Fn9A=";
    url = "https://github.com/ButTaiwan/gensen-font/releases/download/v${version}/GenSenRounded2JP-otf.zip";
  };

  meta = {
    description = "GenSenRounded2 JP Japanese rounded Gothic font family";
    homepage = "https://github.com/ButTaiwan/gensen-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSenRounded2 JP, the Japanese rounded Gothic variant
      of ButTaiwan's GenSenRounded2 Source Han Sans derivative, in
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

  pname = "buttaiwan-gensenrounded2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSenRounded2JP-EL.otf \
      GenSenRounded2JP-L.otf \
      GenSenRounded2JP-R.otf \
      GenSenRounded2JP-M.otf \
      GenSenRounded2JP-B.otf \
      GenSenRounded2JP-H.otf

    runHook postInstall
  '';
}
