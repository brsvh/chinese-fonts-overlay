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

      name = "TsangerMingKai-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳明楷W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-yU0xYmVI2E203xhNdh72Rl4djcLOxDso186dbjs8ebs=";
  w02Src = fetchFont "02" "sha256-6b1E+8kvMkAIapXzFLyX/9UvS6q2soBTzlZpb9VIKuE=";
  w03Src = fetchFont "03" "sha256-BnPhbcRd1ZEqkztZwiIs+2x3sY3vCzeYRey32qXiP0g=";
  w04Src = fetchFont "04" "sha256-/zhji1DR5MYsFlAeT2BuCEKv6Rtzw58mpd2ShmQBIpM=";

  meta = {
    description = "Tsanger Mingkai font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Mingkai font family.

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

  pname = "tsangertype-tsangermingkai";

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
    install -Dm444 ${w01Src} $fontDir/TsangerMingKai-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerMingKai-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerMingKai-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerMingKai-W04.ttf

    runHook postInstall
  '';
}
