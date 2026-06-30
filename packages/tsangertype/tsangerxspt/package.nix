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
    hash = "sha256-+Er3Fl+0Kg4HS/3VKjDP4nxWfUTlvh39cQJwMR0At/E=";
    name = "TsangerXSPT-Regular.ttf";
    url = "https://tsanger.cn/download/仓耳小视频体.ttf";
  };

  meta = {
    description = "TsangerXSPT-Regular font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerXSPT-Regular font.

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

  pname = "tsangertype-tsangerxspt";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerXSPT-Regular.ttf

    runHook postInstall
  '';
}
