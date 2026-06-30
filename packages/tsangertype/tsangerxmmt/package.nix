{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "1.000-unstable-2024-05-24";

  fetchFont =
    weight: hash:
    fetchurl {
      inherit
        hash
        ;

      name = "TsangerXMMT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳小漫漫体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-9q3QfEN7X4QVOW6bGZisO91W6lQYPVZ3+Ka2y7FA4gQ=";
  w02Src = fetchFont "02" "sha256-bri5E0EoeMOAYe7yJjvBdBJGI6/uePvGly+SQ9w128E=";
  w03Src = fetchFont "03" "sha256-RBTYcHZ9bOS2WRZVhDWCRzjZshnCSXbfYGh28fdNUvE=";
  w04Src = fetchFont "04" "sha256-riAKgipJiqqb3xUxpbOwuJbshL0A5RqHyYGHTEakLEI=";
  w05Src = fetchFont "05" "sha256-Axfd84xHmGzEfuBDz3Um99j/iEyOrh+AsMAZ62h9cUg=";

  meta = {
    description = "Tsanger Xiaomanman font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Xiaomanman font family.

      TsangerType states that these fonts are free for personal,
      non-commercial use. Do not use them commercially, redistribute
      the font files, or publish them through a binary cache unless
      TsangerType permits it.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    version
    ;

  pname = "tsangertype-tsangerxmmt";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerXMMT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerXMMT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerXMMT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerXMMT-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerXMMT-W05.ttf

    runHook postInstall
  '';
}
