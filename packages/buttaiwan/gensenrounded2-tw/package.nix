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
    hash = "sha256-xaGMBmHAsm7/5VA0MfL+4XYTf2RRvjrje5eHxhec8yU=";
    url = "https://github.com/ButTaiwan/gensen-font/releases/download/v${version}/GenSenRounded2TW-otf.zip";
  };

  meta = {
    description = "GenSenRounded2 TW Traditional Chinese rounded Gothic font family";
    homepage = "https://github.com/ButTaiwan/gensen-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSenRounded2 TW, the Traditional Chinese modern-use
      rounded Gothic variant of ButTaiwan's GenSenRounded2 Source Han
      Sans derivative, in ExtraLight, Light, Regular, Medium, Bold,
      and Heavy weights.
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

  pname = "buttaiwan-gensenrounded2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSenRounded2TW-EL.otf \
      GenSenRounded2TW-L.otf \
      GenSenRounded2TW-R.otf \
      GenSenRounded2TW-M.otf \
      GenSenRounded2TW-B.otf \
      GenSenRounded2TW-H.otf

    runHook postInstall
  '';
}
