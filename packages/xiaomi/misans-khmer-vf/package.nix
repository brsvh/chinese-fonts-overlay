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

  version = "1.200-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-69YBt39k8FTuEQf5+gAi9XKErm4sM0LJJIk7Mkz5bGA=";
    url = "https://hyperos.mi.com/font-download/MiSans_Khmer.zip";
  };

  meta = {
    description = "MiSans Khmer VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/khmer";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Khmer VF variable TrueType font from
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

  pname = "misans-khmer-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Khmer";

  installPhase = ''
    runHook preInstall

    vfFont="$(find . -name 'MiSansKhmerVF.ttf' -print -quit)"
    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      "$vfFont"

    runHook postInstall
  '';
}
