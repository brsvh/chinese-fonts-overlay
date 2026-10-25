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

  pname = "lxgw-zhenkai";
  version = "0.827";
  legacyVersion = "0.825";

  slabGbSrc = fetchurl {
    hash = "sha256-v06ow5tReERpAgEgElcV0wdRNyM/4ze10Kcyf538A70=";
    url = "https://github.com/lxgw/LxgwZhenKai/releases/download/v${version}/LXGWZhenKaiSlabGB-Regular.ttf";
  };

  gbSrc = fetchurl {
    hash = "sha256-QIdpAqfOJSaKtxCtj+bitjvAAqpLaNIv1F/BJDcmztU=";
    url = "https://github.com/lxgw/LxgwZhenKai/releases/download/v${legacyVersion}/LXGWZhenKaiGB-Regular.ttf";
  };

  gbkSrc = fetchurl {
    hash = "sha256-gheFHr3hJKqErnVKTB1W9BjaYkR2Z6hqSrS4titlexs=";
    url = "https://github.com/lxgw/LxgwZhenKai/releases/download/v${legacyVersion}/ZhenKai_GBK-Regular.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-HuZqIt36UkHUB6X9miumZsTeVwDxcYLV7nKeBDTntC0=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhenKai/v${version}/OFL.txt";
  };

  legacyLicenseSrc = fetchurl {
    hash = "sha256-cWUbHcMODIqxdoZA23joE5yGynrwltmx2MRu2mfutSQ=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhenKai/v${legacyVersion}/OFL.txt";
  };

  meta = {
    description = "LXGW ZhenKai Chinese handwriting fonts";
    homepage = "https://github.com/lxgw/LxgwZhenKai";
    license = licenses.ofl;

    longDescription = ''
      Provides LXGW ZhenKai GB, ZhenKai_GBK, and LXGW ZhenKai Slab GB,
      handwriting fonts derived from LXGW WenKai with heavier strokes.
      Slab GB includes Gungsuh Latin characters, while GBK also uses
      metrics intended for KaiTi documents. GB and GBK retain their
      final 0.825 release.
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
    slabGbSrc
    gbSrc
    gbkSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${slabGbSrc} $fontDir/LXGWZhenKaiSlabGB-Regular.ttf
    install -Dm444 ${gbSrc} $fontDir/LXGWZhenKaiGB-Regular.ttf
    install -Dm444 ${gbkSrc} $fontDir/ZhenKai_GBK-Regular.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt
    install -Dm444 ${legacyLicenseSrc} $docDir/OFL-0.825.txt

    runHook postInstall
  '';
}
