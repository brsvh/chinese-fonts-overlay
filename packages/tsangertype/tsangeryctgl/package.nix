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

      name = "TsangerYCT-GL-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳羽辰体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-XUVbyKxCIvIZ8GahbBJs30Do0K8S8FXfv/0MyxJPwM4=";
  w02Src = fetchFont "02" "sha256-D0i6laYNDxQNFYxXLKVV7GFBvIzCYhnPPi2TQF9jdZQ=";
  w03Src = fetchFont "03" "sha256-J3y4HEP98mmc4d42uAdjDxkAm9rx8HDLUtF5D9zZu98=";
  w04Src = fetchFont "04" "sha256-1mKuir0vXj4Nlhn6Tbv3ShVB9UrzAe7cu1c8dyN7/3Y=";
  w05Src = fetchFont "05" "sha256-F99pe+/+AHMLB7HIjmnLFM7Rm8F5KxVY/ikLmCwQ9/Y=";

  meta = {
    description = "TsangerYCT-GL font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerYCT-GL font family.

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

  pname = "tsangertype-tsangeryctgl";

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
    install -Dm444 ${w01Src} $fontDir/TsangerYCT-GL-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerYCT-GL-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerYCT-GL-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerYCT-GL-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerYCT-GL-W05.ttf

    runHook postInstall
  '';
}
