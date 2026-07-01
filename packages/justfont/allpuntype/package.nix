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

  version = "1.0";

  src = fetchurl {
    hash = "sha256-toWMc8R9c3Dy/A3Z6Ru5nrNGqjZoUxBuOGB/bnKocx4=";
    url = "https://github.com/justfont/AllPunType/releases/download/${version}/AllPunTypeFamily.zip";
  };

  meta = {
    description = "AllPunType Traditional Chinese pun font family";
    homepage = "https://github.com/justfont/AllPunType";
    license = licenses.ofl;

    longDescription = ''
      Provides AllPunType, a Traditional Chinese font family from justfont
      in ExtraLight, Light, Regular, Medium, SemiBold, Bold, and Heavy
      styles. It uses OpenType substitutions to replace homophonic
      Chinese text, selected English text, and Japanese kana with Chinese
      zodiac characters.
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

  pname = "justfont-allpuntype";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/justfont \
      AllPunType-ExtraLight.otf \
      AllPunType-Light.otf \
      AllPunType-Regular.otf \
      AllPunType-Medium.otf \
      AllPunType-SemiBold.otf \
      AllPunType-Bold.otf \
      AllPunType-Heavy.otf

    runHook postInstall
  '';
}
