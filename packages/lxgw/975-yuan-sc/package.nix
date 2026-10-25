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

  pname = "lxgw-975-yuan-sc";
  version = "26.07.26";

  weight400Src = fetchurl {
    hash = "sha256-0U9aRToiFSXw20iHQScSy8A6hNDcRM4tItUdHBNu2aE=";
    url = "https://github.com/lxgw/975Yuan/releases/download/${version}/LXGW975YuanSC-400W.ttf";
  };

  weight500Src = fetchurl {
    hash = "sha256-8qtyTXmUl7nq/tUBUo+8Fbpph3abdnq0UO4o97gbtNg=";
    url = "https://github.com/lxgw/975Yuan/releases/download/${version}/LXGW975YuanSC-500W.ttf";
  };

  weight700Src = fetchurl {
    hash = "sha256-85LeTLqUHzxEx3cM/tesPGWLRrfjpLJUb+FVAQEJ1AM=";
    url = "https://github.com/lxgw/975Yuan/releases/download/${version}/LXGW975YuanSC-700W.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-6cTGJYKAfCUAYeB+3pn0wMfhp9U25iHsaNBJ8ffuDYE=";
    url = "https://raw.githubusercontent.com/lxgw/975Yuan/${version}/OFL.txt";
  };

  meta = {
    description = "LXGW 975 Yuan SC Chinese rounded fonts";
    homepage = "https://github.com/lxgw/975Yuan";
    license = licenses.ofl;

    longDescription = ''
      Provides LXGW 975 Yuan SC in three weights, a Simplified Chinese
      rounded family combining adjusted Chinese glyphs with Baloo 2
      Latin characters.
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
    weight400Src
    weight500Src
    weight700Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${weight400Src} $fontDir/LXGW975YuanSC-400W.ttf
    install -Dm444 ${weight500Src} $fontDir/LXGW975YuanSC-500W.ttf
    install -Dm444 ${weight700Src} $fontDir/LXGW975YuanSC-700W.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';
}
