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

      name = "TsangerShuYuanT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳舒圆体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-s98axqxgM3xoFyrjmdO9f6qWXsdo64xrLPQ72pKc0no=";
  w02Src = fetchFont "02" "sha256-ym0PT/jEscb4xyPtzRw42DNhqAMQQy2axeTPwSp6G3w=";
  w03Src = fetchFont "03" "sha256-8UZhCX42Pu5Nu/kAfvaVqMoeJInMLEtMC9ovbfoJ4Ng=";
  w04Src = fetchFont "04" "sha256-EnrADCL+hE3Y7rEt/XQ3AHpMabDkOhBvYu68xnboxBk=";
  w05Src = fetchFont "05" "sha256-ujQcgbXW1Y7dc6DYvLYWwMPRSfKZ1H0Dxqb1O1hEP+k=";

  meta = {
    description = "Tsanger ShuYuanT font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-freefont-license;

    longDescription = ''
      Provides the Tsanger ShuYuanT font family.

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

  pname = "tsangertype-tsangershuyuant";

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
    install -Dm444 ${w01Src} $fontDir/TsangerShuYuanT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerShuYuanT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerShuYuanT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerShuYuanT-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerShuYuanT-W05.ttf

    runHook postInstall
  '';
}
