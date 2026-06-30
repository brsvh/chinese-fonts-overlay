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

      name = "TsangerTMT-GL-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳天沐体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-+h9LZzZWkKdNj2rqr4/qrn2G2qTJ+GuZumvhhzI4dWo=";
  w02Src = fetchFont "02" "sha256-VXyxFgdOm0beuTtgOR17jmglC54l9a6I0Wvcb/R4WOw=";
  w03Src = fetchFont "03" "sha256-Ktw1ID5SH5IEL4lrT/icuKutCu7Z6UcOKqekNBr6OJ4=";
  w04Src = fetchFont "04" "sha256-lTWWoUHZx6b/3IdbWwwp1YWQyKhqkRKMPV9wBPXvZtU=";
  w05Src = fetchFont "05" "sha256-LqVlqW9XnZ/4dfXxsEj0p8PXEUKSCkA2rP7LPgkUe58=";

  meta = {
    description = "Tsanger Tianmu font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Tianmu font family.

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

  pname = "tsangertype-tsangertmtgl";

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
    install -Dm444 ${w01Src} $fontDir/TsangerTMT-GL-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerTMT-GL-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerTMT-GL-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerTMT-GL-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerTMT-GL-W05.ttf

    runHook postInstall
  '';
}
