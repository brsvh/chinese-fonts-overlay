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

      name = "TsangerQiaoLeTi-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳巧乐体W${weight}.ttf";
    };

  w01Src = fetchFont "01" "sha256-iF+NDEzG9CP459JcBIsNp6pW2HUoToB3E0Wz6+Dbd6E=";
  w02Src = fetchFont "02" "sha256-jVAkF/hmWLz0iss9ygRtjCc9LEZxNjAxkbH5mPSsNHY=";
  w03Src = fetchFont "03" "sha256-d/VnCQVtn95vZ4l+Hd383zkSwDxJnnLDLb6ZDWgHK4g=";
  w04Src = fetchFont "04" "sha256-oR4bCBkXq41lLXsYwyRkT+uYI268vm9zyiHqWWLr84E=";
  w05Src = fetchFont "05" "sha256-//HPd/ZlSd8lrYi+NlG1sYlsa/WgsP/ALyhrKUYNCUw=";

  meta = {
    description = "Tsanger Qiaole font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the Tsanger Qiaole font family.

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

  pname = "tsangertype-tsangerqiaoleti";

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
    install -Dm444 ${w01Src} $fontDir/TsangerQiaoLeTi-W01.ttf
    install -Dm444 ${w02Src} $fontDir/TsangerQiaoLeTi-W02.ttf
    install -Dm444 ${w03Src} $fontDir/TsangerQiaoLeTi-W03.ttf
    install -Dm444 ${w04Src} $fontDir/TsangerQiaoLeTi-W04.ttf
    install -Dm444 ${w05Src} $fontDir/TsangerQiaoLeTi-W05.ttf

    runHook postInstall
  '';
}
