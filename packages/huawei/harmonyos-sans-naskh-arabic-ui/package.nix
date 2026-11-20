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

    homepage = [
      "https://developer.huawei.com/consumer/en/doc/design-guides/font-0000001828772001"
      "https://developer.huawei.com/consumer/en/design/resource/"
    ];

    license = licenses.harmonyos-sans-fonts-license;

    longDescription = ''
      Provides the HarmonyOS Sans Naskh Arabic UI static TrueType
      font family from Huawei Device.

      The HarmonyOS Sans Fonts License Agreement permits embedding
      unmodified fonts in software other than font software, with prominent
      attribution and retained copyright and license notices. Standalone
      redistribution, including through a binary cache, is not permitted.
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
    chinese-fonts-overlay-site = {
      displayName = "HarmonyOS Sans Naskh Arabic UI";
      embedding = true;

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

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "warning";

          text = ''
            HarmonyOS Sans 允许将未修改的字体嵌入或捆绑在字体软件以外的软件中；须在软件中显著注明使用了该字体，并保留版权声明与许可协议。不得修改字体、单独分发或出售字体，也不得将字体包上传到二进制缓存。
          '';

          url = "https://raw.gitcode.com/openharmony/global_system_resources/raw/a52632e5d3901cc860b87fe923142077de194b42/LICENSE_Fonts";
        }
      ];

      styles = [
        "sans"
      ];

      vendor = "huawei";
    };
  };
}
