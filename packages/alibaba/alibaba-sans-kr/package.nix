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

  version = "1.000-unstable-2022-08-10";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-JJNOEId4ut7aCWJDJSe9yPPYE5dCQUXv/KbRD6ucTU4=";
    url = "https://fonts.alibabadesign.com/AlibabaSansKR.zip";
  };

  meta = {
    description = "Alibaba Sans KR font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans KR font family.

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

  pname = "alibaba-sans-kr";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaSansKR";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSansKR-Bold/AlibabaSansKR-Bold.otf \
      AlibabaSansKR-Medium/AlibabaSansKR-Medium.otf \
      AlibabaSansKR-Regular/AlibabaSansKR-Regular.otf

    runHook postInstall
  '';
}
