{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  pname = "lxgw-yozai";
  version = "0.868";

  lightSrc = fetchurl {
    hash = "sha256-DvyEMwiBDATsOU2K8n0Ica2jqcxIYKImq96Iobxns70=";
    url = "https://github.com/lxgw/yozai-font/releases/download/v${version}/Yozai-Light.ttf";
  };

  regularSrc = fetchurl {
    hash = "sha256-JQcZmKD+anL1TCNecUmG0lljPl/2cLGiteJkOH8zFqw=";
    url = "https://github.com/lxgw/yozai-font/releases/download/v${version}/Yozai-Regular.ttf";
  };

  mediumSrc = fetchurl {
    hash = "sha256-BfUPJStFGX0NYUikq8PjfHzUz98DyVW1fCXVPZJPg18=";
    url = "https://github.com/lxgw/yozai-font/releases/download/v${version}/Yozai-Medium.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-hrOgtRYoSFAyQdgOqaMJpkWWkLp9xUeUB1impomlOwI=";
    url = "https://raw.githubusercontent.com/lxgw/yozai-font/v${version}/OFL.txt";
  };

  meta = {
    description = "Yozai Chinese handwriting fonts";
    homepage = "https://github.com/lxgw/yozai-font";
    license = licenses.ofl;

    longDescription = ''
      Provides Yozai in Light, Regular, and Medium weights, a Chinese
      handwriting family derived from Y.OzFont with additional
      Simplified Chinese characters.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    version
    ;

  dontUnpack = true;

  srcs = [
    lightSrc
    regularSrc
    mediumSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${lightSrc} $fontDir/Yozai-Light.ttf
    install -Dm444 ${regularSrc} $fontDir/Yozai-Regular.ttf
    install -Dm444 ${mediumSrc} $fontDir/Yozai-Medium.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';
}
