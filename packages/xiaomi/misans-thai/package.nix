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

  version = "1.003-unstable-2025-07-14";

  src = fetchurl {
    hash = "sha256-hKubMSoKvoUFywCu3+BAterE164Zqf8+mkIvWKEyUO4=";
    url = "https://hyperos.mi.com/font-download/MiSans_Thai.zip";
  };

  meta = {
    description = "MiSans Thai font family";
    homepage = "https://hyperos.mi.com/font/zh/details/thai";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Thai static OpenType font family from
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

  pname = "misans-thai";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Thai";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      otf/MiSansThai-Thin.otf \
      otf/MiSansThai-ExtraLight.otf \
      otf/MiSansThai-Light.otf \
      otf/MiSansThai.otf \
      otf/MiSansThai-Normal.otf \
      otf/MiSansThai-Medium.otf \
      otf/MiSansThai-Demibold.otf \
      otf/MiSansThai-Semibold.otf \
      otf/MiSansThai-Bold.otf \
      otf/MiSansThai-Heavy.otf

    runHook postInstall
  '';
}
