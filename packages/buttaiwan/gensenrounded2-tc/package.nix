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
    hash = "sha256-NGN/LD4APH+4mTM95VIsJr1r6MStnlzxuKJr6lbLQyA=";
    url = "https://github.com/ButTaiwan/gensen-font/releases/download/v${version}/GenSenRounded2TC-otf.zip";
  };

  meta = {
    description = "GenSenRounded2 TC Traditional Chinese rounded Gothic font family";
    homepage = "https://github.com/ButTaiwan/gensen-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSenRounded2 TC, the Traditional Chinese print-style
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

  pname = "buttaiwan-gensenrounded2-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSenRounded2TC-EL.otf \
      GenSenRounded2TC-L.otf \
      GenSenRounded2TC-R.otf \
      GenSenRounded2TC-M.otf \
      GenSenRounded2TC-B.otf \
      GenSenRounded2TC-H.otf

    runHook postInstall
  '';
}
