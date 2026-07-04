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
    hash = "sha256-zkBmNUlR3fI09aBRcHjgNOs9xacQ1y3n5H54FXMeePg=";
    url = "https://hyperos.mi.com/font-download/MiSans_Devanagari.zip";
  };

  meta = {
    description = "MiSans Devanagari VF variable font";
    homepage = "https://hyperos.mi.com/font/zh/details/devanagari";
    license = licenses.mi-sans-font-license;

    longDescription = ''
      Provides the MiSans Devanagari VF variable TrueType font
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

  pname = "misans-devanagari-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "MiSans Devanagari";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/xiaomi \
      MiSans\ Devanagari\ VF.ttf

    runHook postInstall
  '';
}
