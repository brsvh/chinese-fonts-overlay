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
    maintainers
    makeScope
    mapAttrs'
    nameValuePair
    ;
in
makeScope newScope (
  self:
  let
    licenses = lib.licenses // {
      # Gratis propria commercium.
      tsangertype-gpc = {
        free = false;
        fullName = "仓耳字库免费商用字体授权";
        redistributable = true;
        shortName = "tsangertype-gpc-license";
        url = "http://www.tsanger.cn/仓耳字库免费商用字体授权声明.pdf";
      };

      # Gratis propria persona.
      tsangertype-gpp = {
        free = false;
        fullName = "仓耳字库个人非商用字体授权";
        # REVIEW check redistributability.
        # I sent an inquiry via email in March 2024, but I have not
        # received any response yet.
        redistributable = false;
        shortName = "tsangertype-gpp-license";
        # TODO update original license.
        # Their product pages provide only a single line of information,
        # stating that personal, non-commercial use is free of charge.
        url = "http://www.tsanger.cn/TODO";
      };
    };

    mkDerivation =
      name:
      {
        chineseName,
        date,
        gratisProCommercium ? false,
        pinyinName,
        sha256,
        variant ? null,
        weight ? null,
      }:
      let
        canonicalName =
          pinyinName
          + (if variant != null then "-" + variant else "")
          + (if weight != null then "-w" + weight else "");

        meta = {
          license = with licenses; if gratisProCommercium then tsangertype-gpc else tsangertype-gpp;
          description = "${pinyinName} font family distributed by tsangertype";
          longDescription = ''
            ${pinyinName} font${if variant != null then ", variant " + variant else ""}${
              if variant != null then ", weight " + weight else ""
            }.

            This font is ${
              if gratisProCommercium then "gratis propria commercium" else "only gratis propria persona"
            }, origin source is distribute by TsangerType Inc.
          '';
          maintainers = with maintainers; [ brsvh ];
        };

        version = "0-unstable-${date}";

        src = fetchurl {
          name = "tsangertype-" + canonicalName + ".ttf";
          sha256 = "${sha256}";
          url = "http://tsanger.cn/download/${chineseName}.ttf";
        };
      in
      stdenvNoCC.mkDerivation {
        inherit
          meta
          src
          version
          ;

        pname = "tsangertype-${canonicalName}";

        unpackPhase = ''
          :
        '';

        installPhase = ''
          runHook preInstall

          install -Dm444 $src $out/share/fonts/truetype/${canonicalName}.ttf;

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
