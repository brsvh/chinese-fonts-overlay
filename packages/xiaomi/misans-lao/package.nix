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
    description = "MiSans Lao font family";
    homepage = "https://hyperos.mi.com/font/zh/details/lao";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Lao static OpenType font family from
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

  pname = "misans-lao";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    fontRoot="$(find . -maxdepth 1 -type d -name '*MiSans Lao' -print -quit)"
    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      "$fontRoot"/OpenType/MiSansLao-Thin.otf \
      "$fontRoot"/OpenType/MiSansLao-ExtraLight.otf \
      "$fontRoot"/OpenType/MiSansLao-Light.otf \
      "$fontRoot"/OpenType/MiSansLao.otf \
      "$fontRoot"/OpenType/MiSansLao-Normal.otf \
      "$fontRoot"/OpenType/MiSansLao-Medium.otf \
      "$fontRoot"/OpenType/MiSansLao-Demibold.otf \
      "$fontRoot"/OpenType/MiSansLao-Semibold.otf \
      "$fontRoot"/OpenType/MiSansLao-Bold.otf \
      "$fontRoot"/OpenType/MiSansLao-Heavy.otf

    runHook postInstall
  '';
}
