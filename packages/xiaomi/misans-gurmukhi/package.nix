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
    hash = "sha256-VLzIYYXKLNqD8FEo3QbiPrGCbfwbHKb2UljBM0S6VKI=";
    url = "https://hyperos.mi.com/font-download/MiSans_Gurmukhi.zip";
  };

  meta = {
    description = "MiSans Gurmukhi font family";
    homepage = "https://hyperos.mi.com/font/zh/details/gurmukhi";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Gurmukhi static OpenType font family
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

  pname = "misans-gurmukhi";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Gurmukhi";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      otf/MiSansGurmukhi-Thin.otf \
      otf/MiSansGurmukhi-ExtraLight.otf \
      otf/MiSansGurmukhi-Light.otf \
      otf/MiSansGurmukhi.otf \
      otf/MiSansGurmukhi-Normal.otf \
      otf/MiSansGurmukhi-Medium.otf \
      otf/MiSansGurmukhi-Demibold.otf \
      otf/MiSansGurmukhi-Semibold.otf \
      otf/MiSansGurmukhi-Bold.otf \
      otf/MiSansGurmukhi-Heavy.otf

    runHook postInstall
  '';
}
