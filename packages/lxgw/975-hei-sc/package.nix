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

  pname = "lxgw-975-hei-sc";
  version = "26.06.20";

  weight200Src = fetchurl {
    hash = "sha256-nxuHw8UoQSf4F3qlFHY6ZHfqJTse5LBZIzorMb6bfsA=";
    url = "https://github.com/lxgw/975Hei/releases/download/${version}/LXGW975HeiSC-200W.ttf";
  };

  weight300Src = fetchurl {
    hash = "sha256-Ug+RJoGntszPm1AFzCYXEyetNRMNQ9MEUkRHUX22sKk=";
    url = "https://github.com/lxgw/975Hei/releases/download/${version}/LXGW975HeiSC-300W.ttf";
  };

  weight400Src = fetchurl {
    hash = "sha256-pmSC4XFytL+Ym79+bNqqqD5fFdb/Yh75A0vbvvS6BGY=";
    url = "https://github.com/lxgw/975Hei/releases/download/${version}/LXGW975HeiSC-400W.ttf";
  };

  weight500Src = fetchurl {
    hash = "sha256-eYEl0rkUQY3qvuHQ1q3afiJ+XzSerNBbn6H3PrIbMbA=";
    url = "https://github.com/lxgw/975Hei/releases/download/${version}/LXGW975HeiSC-500W.ttf";
  };

  weight700Src = fetchurl {
    hash = "sha256-L8Edl8fM8HFgWokBnzvWa0pk1H7ZSgnGbAr3/9AcmGE=";
    url = "https://github.com/lxgw/975Hei/releases/download/${version}/LXGW975HeiSC-700W.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-hh5DgU9kOs7ogDsN2jQLAojGrhJeicJeCOqlsja+9DU=";
    url = "https://raw.githubusercontent.com/lxgw/975Hei/${version}/OFL.txt";
  };

  meta = {
    description = "LXGW 975 Hei SC Chinese sans-serif fonts";
    homepage = "https://github.com/lxgw/975Hei";
    license = licenses.ofl;

    longDescription = ''
      Provides LXGW 975 Hei SC in five weights, a Simplified Chinese
      sans-serif family derived from Source Han Sans with adjusted
      proportions for screen reading.
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
    weight200Src
    weight300Src
    weight400Src
    weight500Src
    weight700Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${weight200Src} $fontDir/LXGW975HeiSC-200W.ttf
    install -Dm444 ${weight300Src} $fontDir/LXGW975HeiSC-300W.ttf
    install -Dm444 ${weight400Src} $fontDir/LXGW975HeiSC-400W.ttf
    install -Dm444 ${weight500Src} $fontDir/LXGW975HeiSC-500W.ttf
    install -Dm444 ${weight700Src} $fontDir/LXGW975HeiSC-700W.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';
}
