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

      name = "TsangerFFT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳飞飞体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-BbaLD1wZENdegBp6epLkudL1KDRUdC9D4dIROUIdAHw=";
  w02Src = fetchFont "02" "sha256-F00qtZSQkykZAV568q2a5HY/q5Njto91G9tRQVsdDHo=";
  w03Src = fetchFont "03" "sha256-1w53ipJ2SQr8lKr3IBPnauAJXwwqOVufy4VMNEB8sRQ=";
  w04Src = fetchFont "04" "sha256-0NmF7RV0IRQOjiZY6WB2OJDNoTEcCF1Q8q6NNsHLz7o=";

  meta = {
    description = "Tsanger FFT font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger FFT font family.

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

  pname = "tsangertype-tsangerfft";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerFFT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerFFT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerFFT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerFFT-W04.ttf

    runHook postInstall
  '';
}
