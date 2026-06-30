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

  src = fetchurl {
    hash = "sha256-RjlYyUp0ojUfzBUOXwNEWAa5wLzkR83n3JAy5fh7nDQ=";
    name = "TsangerQingJiTi-Regular.ttf";
    url = "https://tsanger.cn/download/仓耳青吉体.ttf";
  };

  meta = {
    description = "TsangerQingJiTi-Regular font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerQingJiTi-Regular font.

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

  pname = "tsangertype-tsangerqingjiti";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerQingJiTi-Regular.ttf

    runHook postInstall
  '';
}
