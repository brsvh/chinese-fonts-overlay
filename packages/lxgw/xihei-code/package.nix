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

  pname = "lxgw-xihei-code";
  version = "26.10.25";

  classicSrc = fetchurl {
    hash = "sha256-HwCh+7A+fBGRxV2RCRJiQI5vlvsiQ/N5KPnHPi11ygA=";
    url = "https://github.com/lxgw/NeoXiHei-Code/releases/download/${version}/XiHeiCode-Regular.ttf";
  };

  neoSrc = fetchurl {
    hash = "sha256-yHuVuliUgpvUtpKnn78mIuRCXnJFB8K/eGIA9EK2LC8=";
    url = "https://github.com/lxgw/NeoXiHei-Code/releases/download/${version}/NeoXiHeiCode-Regular.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-2vkThtb5pqeOTnNsDAA3XK4wIUrFwdqyR58KBfy2Pt0=";
    url = "https://raw.githubusercontent.com/lxgw/NeoXiHei-Code/${version}/License.txt";
  };

  readmeSrc = fetchurl {
    hash = "sha256-+Necd/Cyt/HCoz5C3v+JXIAyFd17PpL0uVUZlEX/fNE=";
    url = "https://raw.githubusercontent.com/lxgw/NeoXiHei-Code/${version}/README.md";
  };

  meta = {
    description = "XiHei Code Chinese monospace fonts";
    homepage = "https://github.com/lxgw/NeoXiHei-Code";
    license = licenses.ipa;

    longDescription = ''
      Provides XiHei Code and NeoXiHei Code, programming fonts derived
      from Migu 1M with monospaced Latin characters from M+ fonts. XiHei
      Code uses Traditional Chinese glyphs from LXGW XiHei, while
      NeoXiHei Code uses glyphs from LXGW Neo XiHei.

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
    neoSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${classicSrc} $fontDir/XiHeiCode-Regular.ttf
    install -Dm444 ${neoSrc} $fontDir/NeoXiHeiCode-Regular.ttf
    install -Dm444 ${licenseSrc} $docDir/License.txt
    install -Dm444 ${readmeSrc} $docDir/README.md

    runHook postInstall
  '';
}
