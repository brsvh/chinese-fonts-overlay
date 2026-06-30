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

      name = "TsangerMingHei-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳明黑W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-VOp/J49utKmuFsYDJc8/5tTluhfhvGG77pLz4ogyPQE=";
  w02Src = fetchFont "02" "sha256-fNp+biBcEum0IBqbUnfl0ty49lnko4u4GLQWLYKXluk=";
  w03Src = fetchFont "03" "sha256-HDMeASk8PJ8+uk1d/4uHg1uGSwTw34iJr5RysQkeYjE=";
  w04Src = fetchFont "04" "sha256-CIQk+yUybE7rOgZg0UH32JO46qtOEuKJne2l/QpfxqU=";
  w05Src = fetchFont "05" "sha256-yEkbLexu4KJsJDwln0X2GSZ+OLDGJ+IzDbi2ZAP4L0U=";
  w06Src = fetchFont "06" "sha256-k3jNP1s4j9odw6XjSODQIACbl2ljPUA6RHnkEsgEmq4=";
  w07Src = fetchFont "07" "sha256-Mvk8iD1u9zDVwYb0c8I8rgVcGjv4Njfv4hcuvM2TTTw=";
  w08Src = fetchFont "08" "sha256-ihMfsGNzKmLyoy+SJP0onZ5q56jIHPmmfN+r1/F9YMw=";

  meta = {
    description = "Tsanger Minghei font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Minghei font family.

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

  pname = "tsangertype-tsangerminghei";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
    w06Src
    w07Src
    w08Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerMingHei-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerMingHei-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerMingHei-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerMingHei-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerMingHei-W05.ttf
    install -Dm444 ${w06Src} $fontDir/TsangerMingHei-W06.ttf
    install -Dm444 ${w07Src} $fontDir/TsangerMingHei-W07.ttf
    install -Dm444 ${w08Src} $fontDir/TsangerMingHei-W08.ttf

    runHook postInstall
  '';
}
