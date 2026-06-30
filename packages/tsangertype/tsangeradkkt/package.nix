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
    hash = "sha256-sfRWWm6E0SuqevmEP8YjptZ0VXp0xEDOoRvWKQzhKyM=";
    name = "TsangerADKKT-W01.ttf";
    url = "https://tsanger.cn/download/仓耳爱的坤坤体.ttf";
  };

  meta = {
    description = "Tsanger ADKKT font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger ADKKT font.

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

  pname = "tsangertype-tsangeradkkt";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 ${src} $out/share/fonts/truetype/tsangertype/TsangerADKKT-W01.ttf

    runHook postInstall
  '';
}
