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

      name = "TsangerZQT-GL-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳知曲体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-yLo0bM2hNJ9nQP1e7VjbP0iDCR34kG1bAyQN9QXWxKQ=";
  w02Src = fetchFont "02" "sha256-j6iXKEcHAEm85tbSKDSTbheJWKK+3mZjp18qagMfP8E=";
  w03Src = fetchFont "03" "sha256-FyCYFuO1sTKUdwgpPY4fFwiUvkCmg31jZ+MB9dxTZfQ=";
  w04Src = fetchFont "04" "sha256-ZG30Itw+W5SEVV/b1Qals3YHa8UwuehOmWTFgQJAG+s=";
  w05Src = fetchFont "05" "sha256-zH4ysN8mvNJxBSnr/rESRXKLIr60DqSgsPTBkxbZ08o=";

  meta = {
    description = "TsangerZQT-GL font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerZQT-GL font family.

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

  pname = "tsangertype-tsangerzqtgl";

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
    install -Dm444 ${w01Src} $fontDir/TsangerZQT-GL-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerZQT-GL-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerZQT-GL-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerZQT-GL-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerZQT-GL-W05.ttf

    runHook postInstall
  '';
}
