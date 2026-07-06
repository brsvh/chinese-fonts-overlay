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
    description = "HarmonyOS Sans Naskh Arabic UI variable font family";
    homepage = "https://developer.huawei.com/consumer/en/design/resource/";
    license = licenses.harmonyos-sans-fonts-license;

    longDescription = ''
      Provides the HarmonyOS Sans Naskh Arabic UI variable
      TrueType font family from Huawei Device.

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

  pname = "harmonyos-sans-naskh-arabic-ui-vf";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "HarmonyOS Sans";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/huawei \
      HarmonyOS_Sans_Naskh_Arabic_UI.ttf

    runHook postInstall
  '';
}
