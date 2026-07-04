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

  version = "4.007-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-0kCRzNQJpBUv/MEs1lnBbfnNzbTHAtiuNVsyHnEfAAQ=";
    url = "https://hyperos.mi.com/font-download/MiSans_Latin.zip";
  };

  meta = {
    description = "MiSans Latin VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/latin";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Latin VF variable TrueType font from
      Xiaomi.

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

  pname = "misans-latin-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Latin";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      */MiSansLatinVF.ttf

    runHook postInstall
  '';
}
