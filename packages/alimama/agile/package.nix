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

  version = "1.000-beta-unstable-2026-01-12";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-TTpuPA6VjaYjRg8o4CK/I800AclvWaCNfvNBI2N6IR8=";
    url = "https://fonts.alibabadesign.com/AlimamaAgileVF.zip";
  };

  meta = {
    description = "Alimama Agile VF font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alimama-agile-license;

    longDescription = ''
      Provides the Alimama Agile VF font family.

      Accept the alimama agile Alimama Lingdongti Legal Statement
      before use. After accepting it, do not redistribute the font
      files or publish them through a binary cache.
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

  pname = "alimama-agile";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/alimama \
      AlimamaAgileVF-Thin.ttf

    runHook postInstall
  '';
}
