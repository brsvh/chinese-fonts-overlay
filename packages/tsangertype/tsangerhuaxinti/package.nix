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
    hash = "sha256-YckbmUI1fBFeRVvd6/FQ73TRJ4X9C9bbciLE5NxNpVQ=";
    name = "TsangerHuaXinTi.ttf";
    url = "https://tsanger.cn/download/仓耳华新体.ttf";
  };

  meta = {
    description = "TsangerHuaXinTi font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerHuaXinTi font.

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

  pname = "tsangertype-tsangerhuaxinti";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerHuaXinTi.ttf

    runHook postInstall
  '';
}
