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
    description = "HarmonyOS Sans Naskh Arabic UI font family";
    homepage = "https://developer.huawei.com/consumer/en/design/resource/";
    license = licenses.harmonyos-sans-fonts-license;

    longDescription = ''
      Provides the HarmonyOS Sans Naskh Arabic UI static TrueType
      font family from Huawei Device.

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

  pname = "harmonyos-sans-naskh-arabic-ui";

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
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_Thin.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_UltraLight.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_Light.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_Regular.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_Medium.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_SemiBold.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_Bold.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_Heavy.ttf" \
      "HarmonyOS Naskh Arabic UI/HarmonyOS_Sans_Naskh_ArabicUI_Black.ttf"

    runHook postInstall
  '';

  passthru = {
    fontInfo = {
      languages = [
        "ar"
        "az-ir"
        "fa"
        "lah"
        "ota"
        "pa-pk"
        "ps-af"
        "ps-pk"
        "ug"
        "ur"
      ];

      licenseCost = "commercialFree";

      notices = [
        {
          level = "warning";

          text = ''
            HarmonyOS Sans 系列字体允许嵌入式使用但不允许再分发，即您必须要伴随网站与应用一起分发字体，不能单独再分发字体，所以请您避免从本地 store 复制这些字体包向他人传播或上传到 substituter server。
          '';
        }
      ];

      styles = [
        "cal"
      ];

      vendor = "huawei";
    };
  };
}
