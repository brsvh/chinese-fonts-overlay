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
    hash = "sha256-88lKweY++uxqGadFsexY0glKRB9YnhsskOXX4dhmUs4=";
    name = "TsangerHST-W01.ttf";
    url = "https://tsanger.cn/download/仓耳寒山体.ttf";
  };

  meta = {
    description = "TsangerHST-W01 font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerHST-W01 font.

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

  pname = "tsangertype-tsangerhst";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerHST-W01.ttf

    runHook postInstall
  '';
}
