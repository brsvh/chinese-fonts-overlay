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

  version = "0.001-unstable-2024-11-18";

  src = fetchurl {
    hash = "sha256-J7LdmKhnP/zXofJu3NoWB/CGHOhCUDC36Vmsul5dyNo=";
    name = "TsangerSongKai.ttf";
    url = "https://tsanger.cn/download/仓耳宋楷.ttf";
  };

  meta = {
    description = "TsangerSongKai font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerSongKai font.

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

  pname = "tsangertype-tsangersongkai";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerSongKai.ttf

    runHook postInstall
  '';
}
