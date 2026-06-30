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
    hash = "sha256-DosLfy4nGOJSPBOhWDaQnpz41Ot5V73ERJm4EgHWDs4=";
    name = "TsangerXHSong-Regular.ttf";
    url = "https://tsanger.cn/download/仓耳星汉宋.ttf";
  };

  meta = {
    description = "TsangerXHSong-Regular font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerXHSong-Regular font.

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

  pname = "tsangertype-tsangerxhsong";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerXHSong-Regular.ttf

    runHook postInstall
  '';
}
