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

      name = "TsangerDDT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳嘟嘟体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-hGYxIxg1wd/4WoyK2uMTMm3pfferCiEu/Kd1t2Mzvdg=";
  w02Src = fetchFont "02" "sha256-jXR+0Rg+dsYgD9WLTwQAAhD3swZO+61g78WXv+qhciA=";
  w03Src = fetchFont "03" "sha256-Ug3+oNIQJssSkMB70dpaLU0seIpn+fXBTGgaOp0qKSA=";
  w04Src = fetchFont "04" "sha256-Ldrs5Vw7Q+9sezCM/G1FxHtuCNP5gsJb5kARif1vcMc=";

  meta = {
    description = "Tsanger DDT font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger DDT font family.

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

  pname = "tsangertype-tsangerddt";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerDDT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerDDT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerDDT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerDDT-W04.ttf

    runHook postInstall
  '';
}
