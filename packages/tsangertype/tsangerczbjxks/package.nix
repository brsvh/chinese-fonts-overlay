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
    hash = "sha256-Lq6MnCtCGpetXT9zbwUMLQUw2cgwpyteLoIx81O2fRE=";
    name = "TsangerCZBJXKS-W01.ttf";
    url = "https://tsanger.cn/download/仓耳曹哲斌俊秀楷书.ttf";
  };

  boldSrc = fetchurl {
    hash = "sha256-siumyOIxbccCLFZtPbEtHdHl9H7rh/JVOmLIpjevEmk=";
    name = "TsangerCZBJXKSJC-W01.ttf";
    url = "https://tsanger.cn/download/仓耳曹哲斌俊秀楷书加粗.ttf";
  };

  meta = {
    description = "Tsanger CZBJXKS font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger CZBJXKS font family.

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

  pname = "tsangertype-tsangerczbjxks";

  dontUnpack = true;

  srcs = [
    regularSrc
    boldSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${regularSrc} $fontDir/TsangerCZBJXKS-W01.ttf
    install -Dm444 ${boldSrc} $fontDir/TsangerCZBJXKSJC-W01.ttf

    runHook postInstall
  '';
}
