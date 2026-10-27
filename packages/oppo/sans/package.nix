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

  pname = "oppo-sans";
  version = "4.0";

  src = fetchurl {
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0"
      "--referer"
      "https://www.coloros.com/article/A00000074/"
    ];

    hash = "sha256-QS0Q/U7YRH4x7skTqb1IFIFs6WFMEuquI/d9yw9U+X0=";
    url = "https://coloros-website-cn.allawnfs.com/font/OPPO_Sans_${version}.zip";
  };

  meta = {
    description = "OPPO Sans 4.0 variable Chinese font";
    homepage = "https://www.coloros.com/article/A00000074/";
    license = licenses.oppo-sans-fonts-license;

    longDescription = ''
      Provides OPPO Sans 4.0 as the original variable TrueType font, with
      a weight axis from 100 to 700 and named Light, Regular, Medium,
      SemiBold, and Bold instances.

      The OPPO Sans Fonts License Agreement permits use and bundling of
      unmodified fonts with software under its terms. Font modification
      and standalone font redistribution are prohibited. Copyright and
      license notices must be retained.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    src
    version
    ;

  nativeBuildInputs = [ unzip ];

  sourceRoot = "OPPO_Sans_${version}";

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/oppo
    install -Dm444 "OPPO Sans 4.0.ttf" $fontDir/OPPOSans4.0.ttf

    runHook postInstall
  '';
}
