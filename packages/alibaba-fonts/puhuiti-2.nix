{
  fetchzip,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    maintainers
    platforms
    ;

  license = {
    free = false;
    fullName = "《阿里巴巴普惠体3.0版》法律声明";
    redistributable = true;
    shortName = "alibaba-puhuiti-license";
    url = "https://www.yuque.com/yiguang-wkqc2/puhuiti/nus9wiinq4aeiegy";
  };

  version = "2.0";

  src = fetchzip {
    hash = "sha256-xmtIDTTy/97zKXuri6FKj/WP97GfkIhJNawFkExKQkc=";
    stripRoot = false;
    url = "https://puhuiti.oss-cn-hangzhou.aliyuncs.com/AlibabaPuHuiTi-2.zip";
  };

  meta = {
    inherit
      license
      ;

    homepage = "https://www.alibabafonts.com";
    description = "An Chinese font gratis propria commercium";
    platforms = platforms.all;
    maintainers = with maintainers; [ brsvh ];
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "alibaba-puhuiti-2";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype/AlibabaFonts

    cp -r $src/AlibabaPuHuiTi-2/* $out/share/fonts/truetype/AlibabaFonts

    runHook postInstall
  '';
}
