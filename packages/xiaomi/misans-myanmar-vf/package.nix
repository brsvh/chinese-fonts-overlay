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

  version = "1.100-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-CH2NC5oR5Il/YGC1/YiWQkOpoBk+WHqSIk75oFcAY/w=";
    url = "https://hyperos.mi.com/font-download/MiSans_Myanmar.zip";
  };

  meta = {
    description = "MiSans Myanmar VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/myanmar";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Myanmar VF variable TrueType font from
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

  pname = "misans-myanmar-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Myanmar";

  installPhase = ''
    runHook preInstall

    vfFont="$(find . -name 'MiSans Myanmar VF.ttf' -print -quit)"
    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      "$vfFont"

    runHook postInstall
  '';
}
