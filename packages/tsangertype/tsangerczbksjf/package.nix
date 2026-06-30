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

  regularSrc = fetchurl {
    hash = "sha256-/7Dk3yPestBS6qoDVeRSyWItwu5xBxYvbPtVdApP9ns=";
    name = "TsangerCZBKSJF-W01.ttf";
    url = "https://tsanger.cn/download/仓耳曹哲斌楷书.ttf";
  };

  boldSrc = fetchurl {
    hash = "sha256-ESPsNg9YOyafsiQ+XFF67oin9SJl6lzUZ3FUxqgqoKw=";
    name = "TsangerCZBKSJC-W01.ttf";
    url = "https://tsanger.cn/download/仓耳曹哲斌楷书加粗.ttf";
  };

  meta = {
    description = "Tsanger CZBKSJF font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger CZBKSJF font family.

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

  pname = "tsangertype-tsangerczbksjf";

  dontUnpack = true;

  srcs = [
    regularSrc
    boldSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${regularSrc} $fontDir/TsangerCZBKSJF-W01.ttf
    install -Dm444 ${boldSrc} $fontDir/TsangerCZBKSJC-W01.ttf

    runHook postInstall
  '';
}
