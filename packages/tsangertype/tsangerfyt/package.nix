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

      name = "TsangerFengYun-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳锋韵W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-06Vp7yb9uG5sb4UV2hNdZO4CExZuooeHktYk8glmlxc=";
  w02Src = fetchFont "02" "sha256-qnPJqpvQdL3/HH7wZ766N41edpOLgo6MFTVEI5Edwag=";
  w03Src = fetchFont "03" "sha256-uUCbgVFkdun7JQWFHc8dDkDVO5oh8KO+fxTAEgMVJf4=";
  w04Src = fetchFont "04" "sha256-B+ELdOUKuQ0azRbT3uO3JIn5xLEpOZJ1sSLrLOm4rsU=";
  w05Src = fetchFont "05" "sha256-4Gp6qICQcwiKIKr73gw/y4ZropVyuDvOmzwoDvS9R84=";
  w06Src = fetchFont "06" "sha256-WPiXFODiDzUSh+sVJs3RuxV9keRNzdEddfSuJcxdS64=";
  w07Src = fetchFont "07" "sha256-VChjBavCi0qE8CVG3+SG5yi2+597Je2uzEjfRyG/yrY=";

  meta = {
    description = "TsangerFengYun font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerFengYun font family.

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

  pname = "tsangertype-tsangerfyt";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
    w06Src
    w07Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerFengYun-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerFengYun-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerFengYun-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerFengYun-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerFengYun-W05.ttf
    install -Dm444 ${w06Src} $fontDir/TsangerFengYun-W06.ttf
    install -Dm444 ${w07Src} $fontDir/TsangerFengYun-W07.ttf

    runHook postInstall
  '';
}
