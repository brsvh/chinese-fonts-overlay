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

      name = "TsangerFWJT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳锋舞九天W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-2sWVrHY7mb/OeeNZdcd8d1K1OgAQplGOf7i83EK/J+M=";
  w02Src = fetchFont "02" "sha256-7H7/+k/s+2SbjpAwn1z52b6m+CARBP7wKDn2VtF3cF4=";
  w03Src = fetchFont "03" "sha256-p1HERtAbFAavkcgZgxkbz3zb7vJrG12vlSadOnc7w3Q=";
  w04Src = fetchFont "04" "sha256-BGtIn8mCTWVT0VQBfNwmxeC+zIJ4DLTHllaBRbJiSIw=";
  w05Src = fetchFont "05" "sha256-dyJcyZwx8ngaZNx0gjYNt5j8LpORLD3QM3snw3AaA7Q=";
  w06Src = fetchFont "06" "sha256-SLPgbvc2lqoqIuFioDlpqTZHSShAVYJQ3v1hIcAHVzs=";

  meta = {
    description = "Tsanger FWJT font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger FWJT font family.

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

  pname = "tsangertype-tsangerfwjt";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
    w06Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerFWJT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerFWJT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerFWJT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerFWJT-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerFWJT-W05.ttf
    install -Dm444 ${w06Src} $fontDir/TsangerFWJT-W06.ttf

    runHook postInstall
  '';
}
