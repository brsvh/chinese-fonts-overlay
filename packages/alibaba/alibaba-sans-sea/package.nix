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

  version = "1.00-unstable-2022-08-02";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-V9TXSxG+r6I1o8XFGbmGRepKP38CW4njHaGWbl2bHFU=";
    url = "https://fonts.alibabadesign.com/AlibabaSansSEA.zip";
  };

  meta = {
    description = "Alibaba Sans SEA font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans SEA font family.

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

  pname = "alibaba-sans-sea";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaSansSEA";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSansSEA-Rg/AlibabaSansSEA-Rg.otf \
      AlibabaSansSEA-Md/AlibabaSansSEA-Md.otf \
      AlibabaSansSEA-Bd/AlibabaSansSEA-Bd.otf

    runHook postInstall
  '';
}
