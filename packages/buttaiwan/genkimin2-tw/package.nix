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
    hash = "sha256-QptxWYmm6+SZGM/xK0iQkF3dX292AjhpTCc0614vao0=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenKiMin2TW-otf.zip";
  };

  meta = {
    description = "GenKiMin2 TW Traditional Chinese modern Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenKiMin2 TW, the Traditional Chinese modern-use variant
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

  pname = "buttaiwan-genkimin2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenKiMin2TW-EL.otf \
      GenKiMin2TW-L.otf \
      GenKiMin2TW-R.otf \
      GenKiMin2TW-M.otf \
      GenKiMin2TW-SB.otf \
      GenKiMin2TW-B.otf \
      GenKiMin2TW-H.otf

    runHook postInstall
  '';
}
