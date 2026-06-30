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

  version = "1.00.00-unstable-2023-02-09";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-Y9FPKipIWPnXJWvwrRbtzLVw5VVa4MVdQUD0r27KuKw=";
    url = "https://fonts.alibabadesign.com/DingTalkJinBuTi.zip";
  };

  meta = {
    description = "DingTalk JinBuTi font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alibaba-font-license;

    longDescription = ''
      Provides the DingTalk JinBuTi font family.

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

  pname = "dingtalk-jinbuti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/dingtalk \
      DingTalkJinBuTi/DingTalkJinBuTi-Regular/DingTalkJinBuTi-Regular.ttf

    runHook postInstall
  '';
}
