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

  version = "1.600-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-Fo/Dvjxuyf5TVQ2mMgFpHJnzKUAsb7hc+KpK28FLlk0=";
    url = "https://hyperos.mi.com/font-download/MiSans_Tibetan.zip";
  };

  meta = {
    description = "MiSans Tibetan font family";
    homepage = "https://hyperos.mi.com/font/zh/details/tibetan";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Tibetan static OpenType font family
      from Xiaomi.

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

  pname = "misans-tibetan";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Tibetan";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      otf/MiSansTibetan-Thin.otf \
      otf/MiSansTibetan-ExtraLight.otf \
      otf/MiSansTibetan-Light.otf \
      otf/MiSansTibetan-Regular.otf \
      otf/MiSansTibetan-Normal.otf \
      otf/MiSansTibetan-Medium.otf \
      otf/MiSansTibetan-Demibold.otf \
      otf/MiSansTibetan-Semibold.otf \
      otf/MiSansTibetan-Bold.otf \
      otf/MiSansTibetan-Heavy.otf

    runHook postInstall
  '';
}
