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

  version = "2.400-unstable-2026-07-06";

  src = fetchurl {
    hash = "sha256-UQJ0+8EugKvmQdew2b1NK7T+wRG3txASI2Sncj/hK9c=";
    url = "https://developer.huawei.com/Enexport/sites/default/images/download/next/HarmonyOS-Sans.rar";
  };

  meta = {
    description = "HarmonyOS Sans font family";
    homepage = "https://developer.huawei.com/consumer/en/design/resource/";
    license = licenses.harmonyos-sans-fonts-license;

    longDescription = ''
      Provides the HarmonyOS Sans, HarmonyOS Sans Condensed,
      HarmonyOS Sans Condensed Italic, and HarmonyOS Sans Italic
      static TrueType font families from Huawei Device.

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

  pname = "harmonyos-sans";

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
      "HarmonyOS_Sans/HarmonyOS_Sans_Thin.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Light.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Regular.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Medium.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Semibold.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Bold.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Black.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Thin.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Light.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Regular.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Medium.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_SemiBold.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Bold.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Black.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Thin.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Light.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Regular.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Medium.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Semibold.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Bold.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Black.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Thin.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Light.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Regular.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Medium.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Semibold.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Bold.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Black.ttf"

    runHook postInstall
  '';
}
