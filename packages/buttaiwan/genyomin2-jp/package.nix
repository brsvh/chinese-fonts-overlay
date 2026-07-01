{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "2.100";

  src = fetchurl {
    hash = "sha256-x8pcqh0SGwuWV/64KCSjDHiBB8FY6NJZPSS9pu1Clvg=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenYoMin2JP-otf.zip";
  };

  meta = {
    description = "GenYoMin2 JP Japanese text Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoMin2 JP, the Japanese text variant of ButTaiwan's
      GenYoMin2 Source Han Serif derivative, in ExtraLight, Light,
      Regular, Medium, SemiBold, Bold, and Heavy weights.
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

  pname = "buttaiwan-genyomin2-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoMin2JP-EL.otf \
      GenYoMin2JP-L.otf \
      GenYoMin2JP-R.otf \
      GenYoMin2JP-M.otf \
      GenYoMin2JP-SB.otf \
      GenYoMin2JP-B.otf \
      GenYoMin2JP-H.otf

    runHook postInstall
  '';
}
