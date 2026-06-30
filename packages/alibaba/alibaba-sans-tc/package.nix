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

  version = "1.00-unstable-2022-08-11";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-6CaB3yCFOFuZnUkfumxB6BEHukBfbgwex6rhUUvsrt0=";
    url = "https://fonts.alibabadesign.com/AlibabaSansTC.zip";
  };

  meta = {
    description = "Alibaba Sans TC font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans TC font family.

      Accept the Alibaba PuHuiTi 3.0 Legal Statement before use.
      After accepting it, do not redistribute the font files or
      publish them through a binary cache.
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

  pname = "alibaba-sans-tc";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaSansTC";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSansTC-45/AlibabaSansTC-45.otf \
      AlibabaSansTC-55/AlibabaSansTC-55.otf \
      AlibabaSansTC-75/AlibabaSansTC-75.otf \
      AlibabaSansTC-95/AlibabaSansTC-95.otf

    runHook postInstall
  '';
}
