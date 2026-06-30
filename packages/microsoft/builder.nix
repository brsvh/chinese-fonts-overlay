{
  lib,
  stdenvNoCC,
  windows-fonts,
  ...
}:
{
  files,
  fontFamily,
  meta ? { },
  pname,
  ...
}@args:
let
  inherit (lib)
    concatStringsSep
    licenses
    maintainers
    platforms
    removeAttrs
    ;

  installFont = file: ''
    install -Dm444 \
      ${windows-fonts}/share/fonts/truetype/microsoft/${file} \
      $fontDir/${file}
  '';

  defaultInstallPhase = ''
      runHook preInstall

      fontDir=$out/share/fonts/truetype/microsoft
      docDir=$out/share/doc/${pname}

      mkdir -p $fontDir $docDir

    ${concatStringsSep "" (map installFont files)}
      install -Dm444 \
        ${windows-fonts}/share/doc/windows-fonts/license.rtf \
        $docDir/license.rtf

      runHook postInstall
  '';

  defaultMeta = {
    description = "Microsoft ${fontFamily} font package";
    homepage = "https://learn.microsoft.com/en-us/typography/fonts/font-faq";
    license = licenses.microsoft-software-license;

    longDescription = ''
      Provides font files for ${fontFamily} copied from the
      windows-fonts package.

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
stdenvNoCC.mkDerivation (
  (removeAttrs args [
    "files"
    "fontFamily"
  ])
  // {
    inherit pname;

    dontUnpack = args.dontUnpack or true;
    installPhase =
      args.installPhase or defaultInstallPhase;
    meta = defaultMeta // meta;
    version = args.version or windows-fonts.version;
  }
)
