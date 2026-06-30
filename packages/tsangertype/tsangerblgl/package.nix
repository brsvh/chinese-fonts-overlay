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

      name = "TsangerBL-GL-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳百灵W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-bD2IYZeU2SnbNtIjX846DyohWIMg2o3M0sJxMDmZJXw=";
  w02Src = fetchFont "02" "sha256-hPxg9TvsiF6usG1vwI+c/G90rjHzzohUwaJiUwk3gHs=";
  w03Src = fetchFont "03" "sha256-Jb5ydG8Ro2z4S6J9WeiBSqeraJEJeFwkEM9ZtBg9460=";
  w04Src = fetchFont "04" "sha256-JyJ5out1wKOVFG858It2FeojeFn7+3XKNZrD1YQKtY8=";
  w05Src = fetchFont "05" "sha256-qRtFT2M1ObrRvFV8OxqS5MnbXlMVZlpDuMhcr8Eew6c=";

  meta = {
    description = "Tsanger Bailing Guli font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Bailing Guli font family.

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

  pname = "tsangertype-tsangerblgl";

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
    install -Dm444 ${w01Src} $fontDir/TsangerBL-GL-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerBL-GL-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerBL-GL-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerBL-GL-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerBL-GL-W05.ttf

    runHook postInstall
  '';
}
