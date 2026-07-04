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

  version = "1.000-unstable-2023-10-18";

  src = fetchurl {
    hash = "sha256-IfU7b2VTZfuWjs+76kfS4lr40sUjFmzRELtPk0gE6NM=";
    url = "https://hyperos.mi.com/font-download/MiSans_Lao.zip";
  };

  meta = {
    description = "MiSans Lao VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/lao";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Lao VF variable TrueType font from
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

  pname = "misans-lao-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    vfFont="$(find . -name 'MiSansLaoVF.ttf' -print -quit)"
    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      "$vfFont"

    runHook postInstall
  '';
}
