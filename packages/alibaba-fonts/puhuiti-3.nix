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

  version = "3.0";

  src = fetchzip {
    hash = "sha256-7ZmurN+sC3binkhABG588Tdvz7KLc06+UvK5TOTjqvY=";
    stripRoot = false;
    url = "https://puhuiti.oss-cn-hangzhou.aliyuncs.com/AlibabaPuHuiTi-3.zip";
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

  pname = "alibaba-puhuiti-3";

  installPhase = ''
    runHook preInstall

    find $src/AlibabaPuHuiTi-3/ -type f -iname "*.ttf" -print0 \
      | xargs -0 install -Dm444 -t $out/share/fonts/truetype/

    runHook postInstall
  '';
}
