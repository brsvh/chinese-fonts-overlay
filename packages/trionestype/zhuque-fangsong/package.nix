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

  version = "0.212";

  src = fetchurl {
    hash = "sha256-u4tmGnZD0ilqctnRBTCgCUlBnE5Sf7YXg/c8K6GowGI=";
    url = "https://github.com/TrionesType/zhuque/releases/download/v${version}/ZhuqueFangsong-v${version}.zip";
  };

  meta = {
    description = "Zhuque Fangsong technical preview font";
    homepage = "https://github.com/TrionesType/zhuque";
    license = licenses.ofl;

    longDescription = ''
      Provides the Zhuque Fangsong technical preview font.
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

  pname = "trionestype-zhuque-fangsong";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/trionestype \
      ZhuqueFangsong-Regular.ttf

    runHook postInstall
  '';
}
