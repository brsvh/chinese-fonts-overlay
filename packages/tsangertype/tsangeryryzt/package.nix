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
    hash = "sha256-I8b+cccfvMtCE3PkD1//ODCukiDfVonjb1rozlfz3fQ=";
    name = "TsangerYRYZT-W01.ttf";
    url = "https://tsanger.cn/download/仓耳易燃易炸体.ttf";
  };

  meta = {
    description = "TsangerYRYZT-W01 font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerYRYZT-W01 font.

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

  pname = "tsangertype-tsangeryryzt";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/truetype/tsangertype/TsangerYRYZT-W01.ttf

    runHook postInstall
  '';
}
