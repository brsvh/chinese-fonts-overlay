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
    hash = "sha256-RcusougTgQ6EtN3vGkz5z2u41e51wcaPDhzfua/IWGM=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenYoMin2TC-otf.zip";
  };

  meta = {
    description = "GenYoMin2 TC Traditional Chinese print Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoMin2 TC, the Traditional Chinese print-style variant
      of ButTaiwan's GenYoMin2 Source Han Serif derivative, in
      ExtraLight, Light, Regular, Medium, SemiBold, Bold, and Heavy
      weights.
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

  pname = "buttaiwan-genyomin2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoMin2TC-EL.otf \
      GenYoMin2TC-L.otf \
      GenYoMin2TC-R.otf \
      GenYoMin2TC-M.otf \
      GenYoMin2TC-SB.otf \
      GenYoMin2TC-B.otf \
      GenYoMin2TC-H.otf

    runHook postInstall
  '';
}
