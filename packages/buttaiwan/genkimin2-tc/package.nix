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
    hash = "sha256-C8Br9ElUli48KcPzO8evxVe0CNfTKVGRQQ8UIC9kp3Q=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenKiMin2TC-otf.zip";
  };

  meta = {
    description = "GenKiMin2 TC Traditional Chinese print Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiMin2 TC, the Traditional Chinese print-style variant
      of ButTaiwan's GenKiMin2 Source Han Serif derivative, in
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

  pname = "buttaiwan-genkimin2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiMin2TC-EL.otf \
      GenKiMin2TC-L.otf \
      GenKiMin2TC-R.otf \
      GenKiMin2TC-M.otf \
      GenKiMin2TC-SB.otf \
      GenKiMin2TC-B.otf \
      GenKiMin2TC-H.otf

    runHook postInstall
  '';
}
