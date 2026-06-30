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

      name = "TsangerXKA-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳小可爱体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-gVQt+eqlUXogMAc+3l4CnZkhPg2OhQOFbuVFdG7WkJg=";
  w02Src = fetchFont "02" "sha256-Yk3CXhyu/BvO20TI2nBPAXzqaLWr1cr0miqDmLzh9FI=";
  w03Src = fetchFont "03" "sha256-Cqpry0u2qsOzX7/Mwj83KYzQNEgMFBZtkFIEAloeeKM=";
  w04Src = fetchFont "04" "sha256-kFpsLhLxXrjqxt3i7foWsx5E3WF/ahDaYp96iY2h7y0=";
  w05Src = fetchFont "05" "sha256-zoWlM9gIqYN6a3yp7GPpq8T3WEkt+r99ODZF35b14cs=";
  w06Src = fetchFont "06" "sha256-FLAoxwwzWHqYIS+mZcDSGKN5fRMX7XkDHbSwDkW9INI=";

  meta = {
    description = "Tsanger Xiaokeai font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Xiaokeai font family.

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

  pname = "tsangertype-tsangerxka";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
    w06Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerXKA-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerXKA-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerXKA-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerXKA-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerXKA-W05.ttf
    install -Dm444 ${w06Src} $fontDir/TsangerXKA-W06.ttf

    runHook postInstall
  '';
}
