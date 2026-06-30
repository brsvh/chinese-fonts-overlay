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

    hash = "sha256-Kj+XeqbW+Per9P+wHwM9/WBkkqmaACtBY8RjBSsWXLY=";
    url = "https://fonts.alibabadesign.com/AlibabaSansHK.zip";
  };

  meta = {
    description = "Alibaba Sans HK font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans HK font family.

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

  pname = "alibaba-sans-hk";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaSansHK";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSansHK-45/AlibabaSansHK-45.otf \
      AlibabaSansHK-55/AlibabaSansHK-55.otf \
      AlibabaSansHK-75/AlibabaSansHK-75.otf \
      AlibabaSansHK-95/AlibabaSansHK-95.otf

    runHook postInstall
  '';
}
