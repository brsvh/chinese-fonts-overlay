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
    hash = "sha256-oPJOVVGD40n88WHVF/+IeZJcKRA8Pv8xZ7gHmvfbMDY=";
    name = "TsangerKuHei.ttf";
    url = "https://tsanger.cn/download/仓耳酷黑.ttf";
  };

  meta = {
    description = "TsangerKuHei font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerKuHei font.

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

  pname = "tsangertype-tsangerkuhei";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerKuHei.ttf

    runHook postInstall
  '';
}
