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
    weight: name: hash:
    fetchurl {
      inherit
        hash
        name
        ;

      url = "https://tsanger.cn/download/仓耳涂鸦体W${weight}.ttf";
    };

  w01Src =
    fetchFont "01" "TsangerTYT-W01.ttf"
      "sha256-ey7EGAPHbhlEAKrh7ZL6IQizt5kwWohwEUZWrQ3fMzo=";
  w02Src =
    fetchFont "02" "TsangerTY-W02-W01.ttf"
      "sha256-dRHfGb23CypXhnyJX7W3e2BgMPmf9qwm5Oz9gAb/+C4=";
  w03Src =
    fetchFont "03" "TsangerTY-W03.ttf"
      "sha256-Kfxa9W333xFDnehvhObuChN9KsP44a6oHuDFC1BD5AQ=";

  meta = {
    description = "Tsanger Tuya font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Tuya font family.

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

  pname = "tsangertype-tsangerty";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerTYT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerTY-W02-W01.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerTY-W03.ttf

    runHook postInstall
  '';
}
