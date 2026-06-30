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

      name = "TsangerLingGang-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳凌刚体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-Ohjftq43hOg3y67FLFCLTFaclh9h5sXlLRKD0SBOKOQ=";
  w02Src = fetchFont "02" "sha256-LZRud5a5D46WUUmj23zXBtfn1y2ilsi1Wmtw4gdyPIY=";
  w03Src = fetchFont "03" "sha256-1v0tnkxfkqx/8+TiiwXgCQT3nbr9/tVThC+X4E3p83Q=";
  w04Src = fetchFont "04" "sha256-VU5wjE0Eb6KbYz78bc0g+sXxfTzoDSegckd73oD6K/4=";
  w05Src = fetchFont "05" "sha256-Fj0VMee2NZ0g2gLxECtd0P8mG+ROaPIfnXcxYZFsTrE=";

  meta = {
    description = "Tsanger Linggang font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Linggang font family.

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

  pname = "tsangertype-tsangerlinggang";

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
    install -Dm444 ${w01Src} $fontDir/TsangerLingGang-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerLingGang-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerLingGang-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerLingGang-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerLingGang-W05.ttf

    runHook postInstall
  '';
}
