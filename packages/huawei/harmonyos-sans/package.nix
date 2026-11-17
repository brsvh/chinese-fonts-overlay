{
  fetchurl,
  lib,
  stdenvNoCC,
  unar,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "2.400-unstable-2026-07-06";

  src = fetchurl {
    hash = "sha256-UQJ0+8EugKvmQdew2b1NK7T+wRG3txASI2Sncj/hK9c=";
    url = "https://developer.huawei.com/Enexport/sites/default/images/download/next/HarmonyOS-Sans.rar";
  };

  meta = {
    description = "HarmonyOS Sans font family";
    homepage = "https://developer.huawei.com/consumer/en/design/resource/";
    license = licenses.harmonyos-sans-fonts-license;

    longDescription = ''
      Provides the HarmonyOS Sans, HarmonyOS Sans Condensed,
      HarmonyOS Sans Condensed Italic, and HarmonyOS Sans Italic
      static TrueType font families from Huawei Device.

      The package uses the HarmonyOS Sans Fonts License Agreement
      and is treated as non-redistributable in this overlay. Do not
      publish the built font files through a binary cache.
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

  pname = "harmonyos-sans";

  nativeBuildInputs = [
    unar
  ];

  unpackPhase = ''
    runHook preUnpack

    unar -quiet -output-directory . $src

    runHook postUnpack
  '';

  sourceRoot = "HarmonyOS-Sans";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/huawei \
      "HarmonyOS_Sans/HarmonyOS_Sans_Thin.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Light.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Regular.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Medium.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Semibold.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Bold.ttf" \
      "HarmonyOS_Sans/HarmonyOS_Sans_Black.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Thin.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Light.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Regular.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Medium.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_SemiBold.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Bold.ttf" \
      "HarmonyOS_Sans_Condensed/HarmonyOS_Sans_Condensed_Black.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Thin.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Light.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Regular.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Medium.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Semibold.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Bold.ttf" \
      "HarmonyOS_Sans_Condensed_Italic/HarmonyOS_SansCondensedItalic_Black.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Thin.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Light.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Regular.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Medium.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Semibold.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Bold.ttf" \
      "HarmonyOS_Sans_Italic/HarmonyOS_SansItalic_Black.ttf"

    runHook postInstall
  '';

  passthru = {
    fontInfo = {
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
        "bin"
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
        "gn"
        "gv"
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ig"
        "ik"
        "io"
        "is"
        "it"
        "kaa"
        "ki"
        "kj"
        "kk"
        "kl"
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
        "miq"
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
        "sk"
        "sl"
        "sm"
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
        "to"
        "tpi"
        "tr"
        "ts"
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

      licenseCost = "commercialFree";

      notices = [
        {
          level = "warning";

          text = ''
            HarmonyOS Sans 系列字体允许嵌入式使用但不允许再分发，即您必须要伴随网站与应用一起分发字体，不能单独再分发字体，所以请您避免从本地 store 复制这些字体包向他人传播或上传到 substituter server。
          '';
        }
      ];

      styles = [
        "sans"
      ];

      vendor = "huawei";
    };
  };
}
