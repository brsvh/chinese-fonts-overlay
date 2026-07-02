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

  version = "1.020";

  src = fetchurl {
    hash = "sha256-KNWK75t6IcE3lFpP0UE41ihKhXPAwbEj9uW3CEIzSKY=";
    url = "https://github.com/ButTaiwan/iansui/releases/download/v${version}/iansui.zip";
  };

  meta = {
    description = "Iansui Traditional Chinese handwriting font";
    homepage = "https://github.com/ButTaiwan/iansui";
    license = licenses.ofl;

    longDescription = ''
      Provides Iansui, a Traditional Chinese handwriting TrueType
      font from ButTaiwan.
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

  pname = "buttaiwan-iansui";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/buttaiwan \
      Iansui-Regular.ttf

    runHook postInstall
  '';
}
