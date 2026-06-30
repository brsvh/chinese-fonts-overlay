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

      name = "TsangerFeiBai-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳非白W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-Ln0AP4plt6hAikSyLXkWNq7Tal088KbU4JTydWbIjec=";
  w02Src = fetchFont "02" "sha256-FPWz94TwoViuOHdMgIj5Rc+HS30cMarmrltrJdvBzIA=";
  w03Src = fetchFont "03" "sha256-4ZVz2/MIBlpFHU/xFyB8RjR1Rx2zNkbMl9Q8RnAOGjs=";
  w04Src = fetchFont "04" "sha256-AORpb3DF4mA14+h/dWyIyUYnNeCGq0RNmGBXYPsZ0As=";
  w05Src = fetchFont "05" "sha256-TlwJPmkN/6DNgpwUNh+ox68GFvFpYKDc2BJjLWwZK+0=";

  meta = {
    description = "Tsanger FeiBai font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-freefont-license;

    longDescription = ''
      Provides the Tsanger FeiBai font family.

      The TsangerType Free Open Source Font Authorization Statement
      permits redistribution but is not a free/libre software
      license. Check its terms before modifying or repackaging the
      font files.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    version
    ;

  pname = "tsangertype-tsangerfeibai";

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
    install -Dm444 ${w01Src} $fontDir/TsangerFeiBai-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerFeiBai-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerFeiBai-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerFeiBai-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerFeiBai-W05.ttf

    runHook postInstall
  '';
}
