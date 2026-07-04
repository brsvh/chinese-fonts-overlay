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
    hash = "sha256-QXgx8DNgHxc4/vss6RWFhtAUM4Wp3QxM+phbzBbHRDs=";
    url = "https://hyperos.mi.com/font-download/MiSans_TC.zip";
  };

  meta = {
    description = "MiSans TC VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/tc";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans TC VF variable TrueType font from
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

  pname = "misans-tc-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans TC";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      */MisansTC\ VF.ttf

    runHook postInstall
  '';
}
