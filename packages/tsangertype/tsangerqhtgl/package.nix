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

      name = "TsangerQHT-GL-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳青禾体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-8NymfD8hiS+fhczrLkNJKKrRWvQ7bSIWbfle0OAt8gU=";
  w02Src = fetchFont "02" "sha256-/8DE3ddX25bZaUY4o2L64INH266CG5R43tTpeixiL9w=";
  w03Src = fetchFont "03" "sha256-H/S9krEtyohctlD0rl4dxwNefpwMbOP2NUPKD+eHXiI=";
  w04Src = fetchFont "04" "sha256-CtM1gn3wjbnIr3Wc82j/6fOqk1kpo/dV0g8RV2GsQuU=";
  w05Src = fetchFont "05" "sha256-0/oqOdf2wFzrDYG3z61hU8HzavAmsJ1nUxaWqEOmEZ0=";

  meta = {
    description = "Tsanger Qinghe font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Qinghe font family.

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

  pname = "tsangertype-tsangerqhtgl";

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
    install -Dm444 ${w01Src} $fontDir/TsangerQHT-GL-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerQHT-GL-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerQHT-GL-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerQHT-GL-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerQHT-GL-W05.ttf

    runHook postInstall
  '';
}
