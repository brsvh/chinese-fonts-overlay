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

  version = "0.001-unstable-2024-05-24";

  src = fetchurl {
    hash = "sha256-4d2cwbj08H04yI++zOZPVhQ1rOzdi7Rw2dW4aDCjU1U=";
    name = "TsangerLiFeiTi-Regular.ttf";
    url = "https://tsanger.cn/download/仓耳利飞体.ttf";
  };

  meta = {
    description = "TsangerLiFeiTi-Regular font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerLiFeiTi-Regular font.

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
    src
    version
    ;

  pname = "tsangertype-tsangerlifeiti";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerLiFeiTi-Regular.ttf

    runHook postInstall
  '';
}
