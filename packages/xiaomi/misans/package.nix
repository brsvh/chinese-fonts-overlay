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

  version = "4.009-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-tqofyCcDWSJhLfjt825WCbyhxUQeJc1XVyIEVpt7gdk=";
    url = "https://hyperos.mi.com/font-download/MiSans.zip";
  };

  meta = {
    description = "MiSans font family";
    homepage = "https://hyperos.mi.com/font/zh/details/sc";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans static OpenType font family from Xiaomi.

      The package uses the MiSans Font Intellectual Property
      License Agreement and is treated as non-redistributable in
      this overlay. Do not publish the built font files through a
      binary cache.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "misans";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      otf/MiSans-Thin.otf \
      otf/MiSans-ExtraLight.otf \
      otf/MiSans-Light.otf \
      otf/MiSans-Regular.otf \
      otf/MiSans-Normal.otf \
      otf/MiSans-Medium.otf \
      otf/MiSans-Demibold.otf \
      otf/MiSans-Semibold.otf \
      otf/MiSans-Bold.otf \
      otf/MiSans-Heavy.otf

    runHook postInstall
  '';
}
