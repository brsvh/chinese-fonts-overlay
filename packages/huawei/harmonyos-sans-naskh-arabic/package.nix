{
  fetchurl,
  lib,
  stdenvNoCC,
  unar,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "2.40-unstable-2026-07-06";

  src = fetchurl {
    hash = "sha256-UQJ0+8EugKvmQdew2b1NK7T+wRG3txASI2Sncj/hK9c=";
    url = "https://developer.huawei.com/Enexport/sites/default/images/download/next/HarmonyOS-Sans.rar";
  };

  meta = {
    description = "HarmonyOS Sans Naskh Arabic font family";
    homepage = "https://developer.huawei.com/consumer/en/design/resource/";
    license = licenses.harmonyos-sans-fonts-license;

    longDescription = ''
      Provides the HarmonyOS Sans Naskh Arabic static TrueType font
      family from Huawei Device.

      The package uses the HarmonyOS Sans Fonts License Agreement
      and is treated as non-redistributable in this overlay. Do not
      publish the built font files through a binary cache.
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

  pname = "harmonyos-sans-naskh-arabic";

  nativeBuildInputs = [
    unar
  ];

  unpackPhase = ''
    runHook preUnpack

    unar -quiet -output-directory . $src

    runHook postUnpack
  '';

  sourceRoot = "HarmonyOS-Sans";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/huawei \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_Thin.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_UltraLight.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_Light.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_Regular.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_Medium.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_SemiBold.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_Bold.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_Heavy.ttf" \
      "HarmonyOS Naskh Arabic/HarmonyOS_Sans_Naskh_Arabic_Black.ttf"

    runHook postInstall
  '';
}
