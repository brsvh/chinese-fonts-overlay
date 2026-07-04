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
    description = "MiSans VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/sc";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans VF variable TrueType font from Xiaomi.

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

  pname = "misans-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      */MiSansVF.ttf

    runHook postInstall
  '';
}
