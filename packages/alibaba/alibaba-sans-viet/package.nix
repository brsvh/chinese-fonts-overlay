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

  version = "1.00-unstable-2022-08-03";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-HNfg/cxvFACuDZJ8gwMfSuyHKAzaxUAjxfRo9DwnjTo=";
    url = "https://fonts.alibabadesign.com/AlibabaSansViet.zip";
  };

  meta = {
    description = "Alibaba Sans Viet font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans Viet font family.

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

  pname = "alibaba-sans-viet";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaSansViet";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSansViet-Rg/AlibabaSansViet-Rg.otf \
      AlibabaSansViet-Md/AlibabaSansViet-Md.otf \
      AlibabaSansViet-Bd/AlibabaSansViet-Bd.otf

    runHook postInstall
  '';
}
