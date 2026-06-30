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

      name = "TsangerYuMo-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳与墨W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-baWW4qFEt6aDY1sp6LgLJlrdwRUdq3EygycLcejS128=";
  w02Src = fetchFont "02" "sha256-LjdczDlymtSgkEY7WBFebo5ncVJqWnq7G45KybQIprc=";
  w03Src = fetchFont "03" "sha256-KA5Che/GMklGslxDkBmerGcHt8LCrCMNTuLeokTosck=";
  w04Src = fetchFont "04" "sha256-2Ora9o/Sy7lqvytRR+GEdz33NOv3vN6o8ajsJZkFsdM=";
  w05Src = fetchFont "05" "sha256-xarDFtdjnXGdoilEDqfevnpa34nbFy8fIl2ivyrlNII=";

  meta = {
    description = "Tsanger YuMo font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-freefont-license;

    longDescription = ''
      Provides the Tsanger YuMo font family.

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

  pname = "tsangertype-tsangeryumo";

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
    install -Dm444 ${w01Src} $fontDir/TsangerYuMo-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerYuMo-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerYuMo-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerYuMo-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerYuMo-W05.ttf

    runHook postInstall
  '';
}
