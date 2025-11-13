{
  fetchurl,
  lib,
  newScope,
  stdenvNoCC,
  xorg,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    filterAttrs
    isDerivation
    makeScope
    mapAttrs'
    nameValuePair
    ;

  licenses = lib.licenses // {
    foundertype-bus = {
      shortName = "foundertype-bus-ula";
      fullName = "方正字库“商业发布”授权说明";
      url = "https://www.foundertype.com/index.php/About/powerbus.html";
      free = false;
      redistributable = false;
    };

    foundertype-per = {
      shortName = "foundertype-per-ula";
      fullName = "方正字库家庭版用户许可协议";
      url = "https://www.foundertype.com/index.php/About/powerPer.html";
      free = false;
      redistributable = false;
    };
  };
in
makeScope newScope (
  self:
  let
    mkDerivation =
      name:
      {
        date,
        per ? false,
        sha256,
      }:
      let
        inherit (lib)
          maintainers
          toLower
          ;

        version = "0-unstable-${date}";

        src = fetchurl {
          sha256 = "${sha256}";
          url = "https://cdn1.foundertype.com/Public/Uploads/ttf/${name}.TTF";
          curlOpts = "--user-agent 'Mozilla/5.0'";
        };

        meta = {
          license = if per then licenses.foundertype-per else licenses.foundertype-bus;
          description = "${name} font distributed by FounderType";
          longDescription = ''
            ${name} font a unfree font distributed by Founder Type.

            This package does not give you any rights to any of its included
            fonts, and only allows users who have obtained a license for
            FounderType to use them.
          '';
          homepage = "https://foundertype.com";
          maintainers = with maintainers; [ brsvh ];
          redistributable = false;
        };
      in
      stdenvNoCC.mkDerivation {
        inherit
          meta
          src
          version
          ;

        pname = "foundertype-${toLower name}";

        preferLocalBuild = true;

        unpackPhase = ''
          :
        '';

        installPhase = ''
          runHook preInstall

          install -Dm444 $src $out/share/fonts/truetype/${name}.ttf;

          runHook postInstall
        '';
      };

    lock = import ./lock.nix;

    fonts = mapAttrs' (n: v: nameValuePair n (mkDerivation n v)) lock;

    combine' =
      name: cond:
      let
        drvs = attrValues (filterAttrs (n: v: isDerivation v && (cond v)) fonts);
      in
      stdenvNoCC.mkDerivation {
        pname = name;

        version = "0-unstable";

        buildInputs = [
          xorg.lndir
        ] ++ drvs;

        unpackPhase = "true";

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          for drv in ${concatStringsSep " " drvs}; do
            ${xorg.lndir}/bin/lndir -silent $drv $out
          done

          runHook postInstall
        '';
      };

    combine = cond: combine' "foundertype-combined-fonts" cond;
  in
  fonts
  // {
    inherit
      combine
      combine'
      ;
  }
)
