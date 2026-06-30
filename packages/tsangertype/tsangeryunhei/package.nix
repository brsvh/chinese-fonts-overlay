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

  version = "1.000-unstable-2024-05-24";

  fetchFont =
    weight: hash:
    fetchurl {
      inherit
        hash
        ;

      name = "TsangerYunHei-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳云黑-W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-FZ51LS+RMzmTI3WntVMzGQRarRbOwjoJevu9KQP0uPw=";
  w02Src = fetchFont "02" "sha256-eEvv5IcYEwbxBDnLukQBrcOV/Z43mA5Lw56c9rDzPPo=";
  w03Src = fetchFont "03" "sha256-XZh0rxx0LVyrFZrLfT13EFvNHhuALaGJoT8BIVWf+E0=";
  w04Src = fetchFont "04" "sha256-RUlL5rcMBizSMfMuqrDe3BtXHD5941oveZgYwo3FIhI=";
  w05Src = fetchFont "05" "sha256-CeRRJP5ECIfHLzDXcJXo9UKZS6qfy0c4cR1V5W/whgE=";
  w06Src = fetchFont "06" "sha256-Z5IH8SmWbstfTmjeY0ekXn27TK9B+zokgSAQ8k40E/k=";
  w07Src = fetchFont "07" "sha256-7unQISFzGNXBN1pMb42EEoO4VZGBSYRZSqyOUUzh8vY=";
  w08Src = fetchFont "08" "sha256-XWqJWDY93OqC1vBDLcLgZWMPn+kOJvfwKW42hpn+n1I=";

  meta = {
    description = "TsangerYunHei font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerYunHei font family.

      TsangerType states that these fonts are free for personal,
      non-commercial use. Do not use them commercially, redistribute
      the font files, or publish them through a binary cache unless
      TsangerType permits it.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    version
    ;

  pname = "tsangertype-tsangeryunhei";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
    w06Src
    w07Src
    w08Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerYunHei-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerYunHei-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerYunHei-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerYunHei-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerYunHei-W05.ttf
    install -Dm444 ${w06Src} $fontDir/TsangerYunHei-W06.ttf
    install -Dm444 ${w07Src} $fontDir/TsangerYunHei-W07.ttf
    install -Dm444 ${w08Src} $fontDir/TsangerYunHei-W08.ttf

    runHook postInstall
  '';
}
