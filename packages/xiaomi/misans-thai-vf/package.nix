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
    description = "MiSans Thai VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/thai";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Thai VF variable TrueType font from
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

  pname = "misans-thai-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Thai";

  installPhase = ''
    runHook preInstall

    vfFont="$(find . -name 'MiSans Thai VF.ttf' -print -quit)"
    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      "$vfFont"

    runHook postInstall
  '';
}
