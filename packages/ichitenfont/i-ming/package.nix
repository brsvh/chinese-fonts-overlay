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

  pname = "ichitenfont-i-ming";
  version = "8.10";

  mingSrc = fetchurl {
    hash = "sha256-y6E7dbBQ1nG2EdAGMUcmLkIeFDWa1FMJSLBw9WER8PM=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.Ming-${version}.ttf";
  };

  mingCpSrc = fetchurl {
    hash = "sha256-HEEaLpe2XCaqoBcHu+BpGVafzXaDyLtdsRSpYmRxBFg=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.MingCP-${version}.ttf";
  };

  mingVarSrc = fetchurl {
    hash = "sha256-uod+0gg1xWIuTL6DtBB+ePEa2RnQJoSR79ANQUGi/Xg=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.MingVar-${version}.ttf";
  };

  mingVarCpSrc = fetchurl {
    hash = "sha256-nTQok7Dt3FuqRjmOueg3QcrYYUPd1JO9uNBCaNeK1Sc=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/I.MingVarCP-${version}.ttf";
  };

  pmingSrc = fetchurl {
    hash = "sha256-S8r/beZ1yreRKgHFCKpJsBvM2s/yY8njFlf34vghBG4=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/PMingI.U-${version}.ttf";
  };

  pmingVarSrc = fetchurl {
    hash = "sha256-/3Qi3ibNFiVoF4omErrt99QJsZGHCl8MkeAKUXMQBc4=";
    url = "https://github.com/ichitenfont/I.Ming/releases/download/${version}/PMingI.UVar-${version}.ttf";
  };

  meta = {
    description = "I.Ming Traditional Chinese serif fonts";
    homepage = "https://github.com/ichitenfont/I.Ming";
    license = licenses.ipa;

    longDescription = ''
      Provides I.Ming, I.MingCP, I.MingVar, I.MingVarCP, PMingI.U, and
      PMingI.UVar. These related serif fonts offer traditional printed
      Chinese forms, alternate glyphs, punctuation metrics, and Windows
      font-matching variants.
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
    mingSrc
    mingCpSrc
    mingVarSrc
    mingVarCpSrc
    pmingSrc
    pmingVarSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/ichitenfont
    install -Dm444 ${mingSrc} $fontDir/I.Ming.ttf
    install -Dm444 ${mingCpSrc} $fontDir/I.MingCP.ttf
    install -Dm444 ${mingVarSrc} $fontDir/I.MingVar.ttf
    install -Dm444 ${mingVarCpSrc} $fontDir/I.MingVarCP.ttf
    install -Dm444 ${pmingSrc} $fontDir/PMingI.U.ttf
    install -Dm444 ${pmingVarSrc} $fontDir/PMingI.UVar.ttf

    runHook postInstall
  '';
}
