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
    hash = "sha256-Rn/gFx7J6iHZJaupwDKxp3Wj51bEWPB156LuV1aLDHk=";
    url = "https://hyperos.mi.com/font-download/MiSans_L3.zip";
  };

  meta = {
    description = "MiSans L3 rare Han character font";
    homepage = "https://hyperos.mi.com/font/zh/rare-word";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans L3 static OpenType font from Xiaomi
      for rare Han characters in GB18030-2022 implementation
      level 3.

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

  pname = "misans-l3";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans L3";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/xiaomi \
      "MiSans L3.otf"

    runHook postInstall
  '';
}
