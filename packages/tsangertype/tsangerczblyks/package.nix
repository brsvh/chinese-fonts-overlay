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
    hash = "sha256-k/U0kzY7eJgA2/6QW5RJ9ucnkaZ3XYYdNuOjgJStMbw=";
    name = "TsangerCZBLYKS-W01.ttf";
    url = "https://tsanger.cn/download/仓耳曹哲斌灵韵楷书.ttf";
  };

  boldSrc = fetchurl {
    hash = "sha256-w8fIaqoqxqSjCxfqjXEoccJnns9ZIff9DaX9+KoxCo8=";
    name = "TsangerCZBLYKSJC-W01.ttf";
    url = "https://tsanger.cn/download/仓耳曹哲斌灵韵楷书加粗.ttf";
  };

  meta = {
    description = "Tsanger CZBLYKS font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger CZBLYKS font family.

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

  pname = "tsangertype-tsangerczblyks";

  dontUnpack = true;

  srcs = [
    regularSrc
    boldSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${regularSrc} $fontDir/TsangerCZBLYKS-W01.ttf
    install -Dm444 ${boldSrc} $fontDir/TsangerCZBLYKSJC-W01.ttf

    runHook postInstall
  '';
}
