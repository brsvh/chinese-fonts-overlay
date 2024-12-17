{
  fetchurl,
  lib,
  stdenvNoCC,
  p7zip,
  ...
}:
let
  inherit (lib)
    maintainers
    platforms
    ;

  license = {
    free = false;
    fullName = "天珩字库协议";
    redistributable = false;
    shortName = "th-license";
    url = "http://cheonhyeong.com/Simplified/download.html";
  };

  version = "4.1.0";

  src = fetchurl {
    url = "http://cheonhyeong.com/File/TH-Sung-T${version}.7z";
    hash = "sha256-Erp4sv25qqnXBR4VGCcKTHOqZmx5P+xlCMkROlSo/mE=";
  };

  meta = {
    inherit license;

    description = "A font package which has the largest quantity of glyphs";
    homepage = "http://cheonhyeong.com";
    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "TH-Sung-T";

  nativeBuildInputs = [
    p7zip
  ];

  unpackPhase = ''
    runHook preUnpack

    tempdir=$(mktemp -d)

    7z x $src -o$tempdir -y

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    find $tempdir -type f \( -iname "*.ttf" -o -iname "*.ttc" \) -print0 \
      | xargs -0 install -Dm444 -t $out/share/fonts/truetype/

    runHook postInstall
  '';
}
