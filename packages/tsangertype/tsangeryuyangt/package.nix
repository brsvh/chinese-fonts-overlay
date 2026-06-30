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

      name = "TsangerYuYangT-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳渔阳体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-SjxVZoWAN9MeopC51DbdP2NrMMTjUK7/Dc1evfcfQHE=";
  w02Src = fetchFont "02" "sha256-P+TQ1T+kKbS2Y9jEAag7sMakCjgUwIGwujE+J9GAIPo=";
  w03Src = fetchFont "03" "sha256-Q7OB1ExvZmgzhLKPmFIVpvXQGXbW8BsKoBHQSIFGKDU=";
  w04Src = fetchFont "04" "sha256-5PKgZI9hbcTkT7SCtDaj4byRboq1Cdbka+tIINxeawc=";
  w05Src = fetchFont "05" "sha256-Z/THDB+7aTXfsJI2lbw6uIL/nuJKsoWf4I/tzMqqdaE=";

  meta = {
    description = "Tsanger YuYangT font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-freefont-license;

    longDescription = ''
      Provides the Tsanger YuYangT font family.

      The TsangerType Free Open Source Font Authorization Statement
      permits redistribution but is not a free/libre software
      license. Check its terms before modifying or repackaging the
      font files.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    version
    ;

  pname = "tsangertype-tsangeryuyangt";

  dontUnpack = true;

  srcs = [
    w01Src
    w02Src
    w03Src
    w04Src
    w05Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${w01Src} $fontDir/TsangerYuYangT-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerYuYangT-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerYuYangT-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerYuYangT-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerYuYangT-W05.ttf

    runHook postInstall
  '';
}
