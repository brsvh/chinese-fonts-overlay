{
  fetchurl,
  lib,
  p7zip,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "26200.6584.250915-1905";

  src = fetchurl {
    hash = "sha256-e0rIc5G2WfdyQiloK2QiViiaHABQQFYknw8SApFX09I=";
    url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_zh-cn.iso";
  };

  meta = {
    description = "Microsoft Windows 11 zh-CN font collection";
    homepage = "https://learn.microsoft.com/en-us/typography/fonts/font-faq";
    license = licenses.microsoft-software-license;

    longDescription = ''
      Provides the Microsoft Windows 11 zh-CN font collection.

      Obtain a valid license under the Microsoft Software License
      Terms before use. After obtaining it, do not redistribute the
      font files or publish them through a binary cache unless that
      license permits it.
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

  pname = "windows-fonts";

  nativeBuildInputs = [
    p7zip
  ];

  preferLocalBuild = true;

  unpackPhase = ''
    runHook preUnpack

    tempdir=$(mktemp -d)

    7z x $src -o$tempdir

    mkdir fonts licenses

    7z e \
      $tempdir/sources/install.wim \
      Windows/Fonts/"*".ttf \
      Windows/Fonts/"*".ttc \
      -ofonts

    7z e \
      $tempdir/sources/install.wim \
      Windows/System32/zh-CN/Licenses/Eval/EnterpriseEval/license.rtf \
      -olicenses

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 fonts/* \
      -t $out/share/fonts/truetype/microsoft

    install -Dm444 \
      licenses/license.rtf \
      $out/share/doc/windows-fonts/license.rtf

    runHook postInstall
  '';
}
