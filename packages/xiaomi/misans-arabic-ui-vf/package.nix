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

  version = "1.002-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-8sxJOdIC1sZFxcsGEz+998qkINQyUGgvnTeSiEyLcuU=";
    url = "https://hyperos.mi.com/font-download/MiSans_Arabic.zip";
  };

  meta = {
    description = "MiSans Arabic UI VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/arabic";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Arabic UI VF variable TrueType font from
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

  pname = "misans-arabic-ui-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Arabic/MiSans Arabic UI";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      */MiSansArabicUIVF.ttf

    runHook postInstall
  '';
}
