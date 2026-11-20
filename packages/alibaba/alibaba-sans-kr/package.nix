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
    homepage = "https://www.alibabafonts.com/#/font";
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

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "阿里巴巴普惠体韩文";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "az-az"
        "be"
        "bem"
        "bg"
        "bi"
        "br"
        "bs"
        "bua"
        "ca"
        "ce"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
        "el"
        "en"
        "eo"
        "es"
        "et"
        "eu"
        "fi"
        "fil"
        "fj"
        "fo"
        "fr"
        "fur"
        "fy"
        "gd"
        "gl"
        "gv"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ik"
        "io"
        "is"
        "it"
        "kaa"
        "ki"
        "kj"
        "kk"
        "kl"
        "ko"
        "ku-tr"
        "kum"
        "kwm"
        "ky"
        "la"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "lt"
        "lv"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mjw"
        "mk"
        "mn-mn"
        "mo"
        "ms"
        "mt"
        "na"
        "nb"
        "nds"
        "ng"
        "nhn"
        "niu"
        "nl"
        "nn"
        "no"
        "nr"
        "nso"
        "ny"
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sc"
        "se"
        "sel"
        "sg"
        "sgs"
        "shs"
        "sk"
        "sl"
        "sma"
        "smj"
        "smn"
        "sn"
        "sq"
        "sr"
        "ss"
        "st"
        "sv"
        "sw"
        "szl"
        "tk"
        "tn"
        "tpi"
        "tr"
        "ts"
        "tt"
        "ty"
        "tyv"
        "uk"
        "unm"
        "uz"
        "vo"
        "vot"
        "wa"
        "wae"
        "wen"
        "wo"
        "xh"
        "yap"
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "warning";

          text = ''
            阿里巴巴（中国）有限公司版权所有的字体未明确允许嵌入式使用，嵌入场景未经明确豁免会受再分发限制约束，所以建议不以嵌入式方式使用。
          '';
        }
      ];

      styles = [
        "hei"
        "sans"
      ];

      vendor = "alibaba";
    };
  };
}
