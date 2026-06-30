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

    hash = "sha256-YIW7e8Jyu5dc2Y4l4Qd9KxwEfDEnmvNn5TiS7GMCDS0=";
    url = "https://fonts.alibabadesign.com/AlibabaSansJP.zip";
  };

  meta = {
    description = "Alibaba Sans JP font family";
    homepage = "https://www.alibabafonts.com";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the Alibaba Sans JP font family.

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

  pname = "alibaba-sans-jp";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = "AlibabaSansJP";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alibaba \
      AlibabaSansJP-Bold/AlibabaSansJP-Bold.otf \
      AlibabaSansJP-Medium/AlibabaSansJP-Medium.otf \
      AlibabaSansJP-Regular/AlibabaSansJP-Regular.otf

    runHook postInstall
  '';
}
