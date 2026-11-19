{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "0-unstable-2016-08-15";

  src = fetchurl {
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-uTQo4DUwAQ4ujBASo6ovymjJlQ86H7bviOG0UW5tAGQ=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZLSK.TTF";
  };

  meta = {
    description = "FZLiShu font distributed by FounderType";
    homepage = "https://www.foundertype.com/index.php/FontInfo/index/id/141";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZLiShu font.

      Obtain the FounderType authorization appropriate to the intended
      use. Free trials offered to registered professional designers
      do not grant general personal or commercial usage rights.
      Do not redistribute font files or publish them through a binary
      cache without permission.
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

  pname = "foundertype-fzlishu";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZLSK.TTF
    ln -s FZLSK.TTF $fontDir/FZLSK.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "方正隶书";

      languages = [
        "agr"
        "bem"
        "bg"
        "cmn"
        "fj"
        "hak"
        "ho"
        "ia"
        "io"
        "kj"
        "kum"
        "kwm"
        "lzh"
        "mhr"
        "ms"
        "ng"
        "nr"
        "om"
        "os"
        "rn"
        "ru"
        "rw"
        "sel"
        "sn"
        "ss"
        "st"
        "sw"
        "ts"
        "uz"
        "xh"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "paid";

      notices = [
        {
          level = "caution";

          text = ''
            本字体属于方正基础字体，发布使用需按用途取得授权；出版物和嵌入式应用需要相应的专项授权。未经许可，不得将字体文件再分发或上传到二进制缓存。
          '';

          url = "https://www.foundertype.com/index.php/About/powerbus.html";
        }
      ];

      styles = [
        "li"
      ];

      vendor = "foundertype";
    };
  };
}
