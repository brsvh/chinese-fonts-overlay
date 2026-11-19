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

    hash = "sha256-puTh7oh4uCS062bcWOJe0lWZLvOskBJkuERKW8WjACk=";
    url = "https://cdn1.foundertype.com/Public/Uploads/ttf/FZXBSK.TTF";
  };

  meta = {
    description = "FZXiaoBiaoSong font distributed by FounderType";
    homepage = "https://www.foundertype.com/index.php/FontInfo/index/id/164";
    license = licenses.foundertype-commercial-license;

    longDescription = ''
      Provides the FZXiaoBiaoSong font.

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

  pname = "foundertype-fzxiaobiaosong";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/foundertype
    install -Dm444 $src $fontDir/FZXBSK.TTF
    ln -s FZXBSK.TTF $fontDir/FZXBSK.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "方正小标宋";

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
        "serif"
        "song"
      ];

      vendor = "foundertype";
    };
  };
}
