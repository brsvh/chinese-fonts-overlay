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

  pname = "lxgw-xihei";
  version = "1.002";

  classicSrc = fetchurl {
    hash = "sha256-fEN7vQXqsAWXgCkKceDvcEzSRoQzsoxypcevovIwpQg=";
    url = "https://github.com/lxgw/LxgwXiHei/releases/download/v${version}/LXGWXiHeiCL.ttf";
  };

  modernSrc = fetchurl {
    hash = "sha256-G8Vue54YRp78Qp3KpjpkogUFo4vHhBjgw50JSqhiRRQ=";
    url = "https://github.com/lxgw/LxgwXiHei/releases/download/v${version}/LXGWXiHeiMN.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-oYax861LjVakPclmN85V9apPREYCXWJHZB1O8TxLsps=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwXiHei/v${version}/LICENSE.md";
  };

  readmeSrc = fetchurl {
    hash = "sha256-Hleovl/DA8PQhycuhpayxc/sBwCtn06X/nQKq24dcNU=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwXiHei/v${version}/README.md";
  };

  meta = {
    description = "LXGW XiHei Traditional Chinese sans-serif fonts";
    homepage = "https://github.com/lxgw/LxgwXiHei";
    license = licenses.ipa;

    longDescription = ''
      Provides the Classic and Modern variants of LXGW XiHei, a
      Traditional Chinese sans-serif family derived from IPAex Gothic.
      Classic follows traditional printed forms and merges selected
      source-separated characters; Modern balances printed forms with
      contemporary component conventions and preserves those characters.

      The IPA Font License 1.0 permits commercial use. Redistribution
      must preserve the license and provide a way to replace the font
      with the original IPA font; modified versions must use the same
      license.
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
    classicSrc
    modernSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${classicSrc} $fontDir/LXGWXiHeiCL.ttf
    install -Dm444 ${modernSrc} $fontDir/LXGWXiHeiMN.ttf
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md
    install -Dm444 ${readmeSrc} $docDir/README.md

    runHook postInstall
  '';
}
