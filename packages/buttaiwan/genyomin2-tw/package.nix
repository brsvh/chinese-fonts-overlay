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
    hash = "sha256-ZO0hou87Qhcb3e1VpwWzLMEFdAQ2yfYcPW7+yVp2lxg=";
    url = "https://github.com/ButTaiwan/genyo-font/releases/download/v${version}/GenYoMin2TW-otf.zip";
  };

  meta = {
    description = "GenYoMin2 TW Traditional Chinese modern Mincho font family";
    homepage = "https://github.com/ButTaiwan/genyo-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenYoMin2 TW, the Traditional Chinese modern-use variant
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

  pname = "buttaiwan-genyomin2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenYoMin2TW-EL.otf \
      GenYoMin2TW-L.otf \
      GenYoMin2TW-R.otf \
      GenYoMin2TW-M.otf \
      GenYoMin2TW-SB.otf \
      GenYoMin2TW-B.otf \
      GenYoMin2TW-H.otf

    runHook postInstall
  '';
}
