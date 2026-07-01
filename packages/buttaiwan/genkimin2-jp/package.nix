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
    hash = "sha256-UXz6GpYXEd8U4lerselhWgOn3smDUXr1HY+7KlPOvjQ=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenKiMin2JP-otf.zip";
  };

  meta = {
    description = "GenKiMin2 JP Japanese text Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiMin2 JP, the Japanese text variant of ButTaiwan's
      GenKiMin2 Source Han Serif derivative, in ExtraLight, Light,
      Regular, Medium, SemiBold, Bold, and Heavy weights.
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

  pname = "buttaiwan-genkimin2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiMin2JP-EL.otf \
      GenKiMin2JP-L.otf \
      GenKiMin2JP-R.otf \
      GenKiMin2JP-M.otf \
      GenKiMin2JP-SB.otf \
      GenKiMin2JP-B.otf \
      GenKiMin2JP-H.otf

    runHook postInstall
  '';
}
