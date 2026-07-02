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
    hash = "sha256-Y1yiVzmVYC4hHafO2koF1dRW3vwEYc4AW5WPwhBQcRY=";
    url = "https://github.com/ButTaiwan/genwan-font/releases/download/v${version}/GenWanMin2JP-otf.zip";
  };

  meta = {
    description = "GenWanMin2 JP Japanese text Mincho font family";
    homepage = "https://github.com/ButTaiwan/genwan-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenWanMin2 JP, the Japanese text variant of
      ButTaiwan's GenWanMin2 Source Han Serif derivative, in
      ExtraLight, Light, Regular, Medium, and SemiBold weights.
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

  pname = "buttaiwan-genwanmin2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenWanMin2JP-EL.otf \
      GenWanMin2JP-L.otf \
      GenWanMin2JP-R.otf \
      GenWanMin2JP-M.otf \
      GenWanMin2JP-SB.otf

    runHook postInstall
  '';
}
