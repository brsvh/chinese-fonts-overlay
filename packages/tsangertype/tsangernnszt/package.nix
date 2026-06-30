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

  version = "1.000-unstable-2026-06-30";

  src = fetchurl {
    hash = "sha256-9zHJkKXtK19vW26cL9lTDT1+O/SUruEuU4W7EyQuEio=";
    name = "TsangerNNSZT-W01.ttf";
    url = "https://tsanger.cn/download/仓耳暖男手札体.ttf";
  };

  meta = {
    description = "TsangerNNSZT-W01 font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerNNSZT-W01 font.

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

  pname = "tsangertype-tsangernnszt";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerNNSZT-W01.ttf

    runHook postInstall
  '';
}
