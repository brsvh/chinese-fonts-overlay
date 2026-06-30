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

      name = "TsangerYiHei-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳逸黑W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-lvbw2ZnBrZNU4079G7LQfi70L5yfVjErTojsgC7V8Bo=";
  w02Src = fetchFont "02" "sha256-qAx8T1aCsf6nDCL6JEPkRkmB9Aal91htcIPBoXhvt64=";
  w03Src = fetchFont "03" "sha256-MKcFQkDPtvK+YG36czA5s7ePJz5/v6/NpyA/uHV2flg=";
  w04Src = fetchFont "04" "sha256-3hIl917Kr3U15OUuRc4lAvDmx0W9S+Haufglu0GRwKk=";
  w05Src = fetchFont "05" "sha256-SrfAO+DhWFVjprWWQ2a28twZIFSlnBJzqNAKlvEFuyg=";

  meta = {
    description = "TsangerYiHei font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerYiHei font family.

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

  pname = "tsangertype-tsangeryihei";

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
    install -Dm444 ${w01Src} $fontDir/TsangerYiHei-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerYiHei-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerYiHei-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerYiHei-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerYiHei-W05.ttf

    runHook postInstall
  '';
}
