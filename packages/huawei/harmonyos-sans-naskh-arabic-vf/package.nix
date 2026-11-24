{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "1.401-unstable-2026-06-27";

  src = fetchurl {
    hash = "sha256-VECj2TN4KO2nLjX0j7skaHO8om6JZE1DOosBuF5F74U=";
    url = "https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyManage/011/111/111/0000000000011111111.20260627152129.89276966309836366526585265125586:50001231000000:2800:A0161E048334FE0271F9F5ECBBD5070D17381C7846125F4D7109DBC7B532C715.zip";
  };

  meta = {
    description = "HarmonyOS Sans Naskh Arabic variable font family";

    homepage = [
      "https://developer.huawei.com/consumer/en/doc/design-guides/font-0000001828772001"
      "https://developer.huawei.com/consumer/en/design/resource/"
    ];

    license = licenses.harmonyos-sans-fonts-license;

    longDescription = ''
      Provides the HarmonyOS Sans Naskh Arabic variable TrueType
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

  pname = "harmonyos-sans-naskh-arabic-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "HarmonyOS Sans";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/huawei \
      HarmonyOS_Sans_Naskh_Arabic.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "HarmonyOS Sans Naskh Arabic VF";
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
