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
    hash = "sha256-WY6V/2JpV8omx06uQSsUOU/PUGLCzRdFPRjNtphD1pU=";
    name = "TsangerZhoukeZhengdabangshu.ttf";
    url = "https://tsanger.cn/download/仓耳周珂正大榜书.ttf";
  };

  meta = {
    description = "Tsanger Zhouke Zhengdabangshu font";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-freefont-license;

    longDescription = ''
      Provides the Tsanger Zhouke Zhengdabangshu font.

      The TsangerType Free Open Source Font Authorization Statement
      permits redistribution but is not a free/libre software
      license. Check its terms before modifying or repackaging the
      font files.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "tsangertype-tsangerzhoukezhengdabangshu";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 ${src} $out/share/fonts/truetype/tsangertype/TsangerZhoukeZhengdabangshu.ttf

    runHook postInstall
  '';
}
