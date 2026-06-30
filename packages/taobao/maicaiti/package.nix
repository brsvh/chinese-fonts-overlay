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

  version = "1.000-unstable-2024-09-25";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-tf15bD1+6vDBOKbmeEMJ6/GOYPiNPOAYV0NZ0KmgHc0=";
    url = "https://fonts.alibabadesign.com/TaoBaoMaiCaiTi.zip";
  };

  meta = {
    description = "Taobao MaiCaiTi font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.taobao-maicaiti-license;

    longDescription = ''
      Provides the Taobao MaiCaiTi font family.

      Accept the Taobao MaiCaiTi Legal Statement before use. After
      accepting it, do not redistribute the font files or publish
      them through a binary cache.
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

  pname = "taobao-maicaiti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "TaoBaoMaiCaiTi-Regular";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/taobao \
      TaoBaoMaiCaiTi-Regular.otf

    runHook postInstall
  '';
}
