{
  chinese-fonts-overlay-lib,
  projectRoot,
  ...
}:
final: prev:
let
  inherit (chinese-fonts-overlay-lib)
    filterDerivations
    ;

  inherit (final)
    lndir
    stdenvNoCC
    ;

  lib = prev.lib.extend (
    _: prevAttrs: {
      licenses =
        prevAttrs.licenses
        // chinese-fonts-overlay-lib.licenses;
    }
  );

  inherit (lib)
    concatStringsSep
    elem
    makeScope
    packagesFromDirectoryRecursive
    removeAttrs
    ;

  mkFontCollection =
    scope: pname: condition:
    let
      members = filterDerivations condition scope;
    in
    stdenvNoCC.mkDerivation {
      inherit
        pname
        ;

      dontUnpack = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out

        for drv in ${concatStringsSep " " members}; do
          ${lndir}/bin/lndir -silent $drv $out
        done

        runHook postInstall
      '';

      passthru = {
        isFontAggregate = true;
        fontMembers = members;
      };

      version = "0";
    };

  mkVendorPackages =
    vendor:
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final) callPackage newScope;
        directory = projectRoot + "/packages/${vendor}";
      };
    in
    packages
    // {
      combine = mkFontCollection packages "${vendor}-fonts";
      combine' = mkFontCollection packages;
    };

  alibabaPackages = mkVendorPackages "alibaba";

  alimamaPackages = mkVendorPackages "alimama";

  buttaiwanPackages = mkVendorPackages "buttaiwan";

  cwtexPackages = mkVendorPackages "cwtex";

  dingtalkPackages = mkVendorPackages "dingtalk";

  foundertypeCtexPackages =
    with foundertypePackages; [
      fzfangsong
      fzheiti
      fzkaiti
      fzlishu
      fzshusong
      fzxiaobiaosong
      fzxiheiyi
      fzxiyuan
      fzzhunyuan
    ];

  foundertypePackages = mkVendorPackages "foundertype";

  foundertypePaidPackages =
    with foundertypePackages; [
      fzcuyuan
      fzlishu
      fzxiaobiaosong
      fzxiheiyi
      fzxiyuan
      fzzhunyuan
    ];

  hanwangPackages = mkVendorPackages "hanwang";

  huaweiPackages = mkVendorPackages "huawei";

  harmonyosSansPackages = with huaweiPackages; [
    harmonyos-sans
    harmonyos-sans-naskh-arabic
    harmonyos-sans-naskh-arabic-ui
    harmonyos-sans-sc
    harmonyos-sans-tc
  ];

  harmonyosSansVfPackages = with huaweiPackages; [
    harmonyos-sans-naskh-arabic-ui-vf
    harmonyos-sans-naskh-arabic-vf
    harmonyos-sans-sc-vf
    harmonyos-sans-tc-vf
    harmonyos-sans-vf
  ];

  ichitenfontPackages = mkVendorPackages "ichitenfont";

  itoPackages = mkVendorPackages "ito";

  jikaseiPackages = mkVendorPackages "jikasei";

  justfontPackages = mkVendorPackages "justfont";

  lingdongPackages = mkVendorPackages "lingdong";

  lxgwPackages = mkVendorPackages "lxgw";

  microsoftPackages =
    let
      packageScope = makeScope final.newScope (
        self:
        let
          packages = packagesFromDirectoryRecursive {
            inherit (self)
              callPackage
              newScope
              ;

            directory = projectRoot + /packages/microsoft;
          };
        in
        packages
        // {
          mkMicrosoftFontDerivation = self.callPackage (
            projectRoot + /packages/microsoft/builder.nix
          ) { };
        }
      );

      fontPackages = removeAttrs packageScope [
        "builder"
        "mkMicrosoftFontDerivation"
        "windows-fonts"
      ];

      allPackages = removeAttrs packageScope [
        "builder"
        "mkMicrosoftFontDerivation"
      ];
    in
    allPackages
    // {
      combine = mkFontCollection fontPackages "windows-fonts";

      combine' = mkFontCollection fontPackages;
    };

  naverPackages = mkVendorPackages "naver";

  oppoPackages = mkVendorPackages "oppo";

  tanukiPackages = mkVendorPackages "tanuki";

  taobaoPackages = mkVendorPackages "taobao";

  tianhengPackages = mkVendorPackages "tianheng";

  trionestypePackages = mkVendorPackages "trionestype";

  tsangertypePackages = mkVendorPackages "tsangertype";

  xiaomiPackages = mkVendorPackages "xiaomi";
in
{
  inherit
    alibabaPackages
    alimamaPackages
    buttaiwanPackages
    cwtexPackages
    dingtalkPackages
    foundertypePackages
    hanwangPackages
    huaweiPackages
    ichitenfontPackages
    itoPackages
    jikaseiPackages
    justfontPackages
    lib
    lingdongPackages
    lxgwPackages
    microsoftPackages
    naverPackages
    oppoPackages
    tanukiPackages
    taobaoPackages
    tianhengPackages
    trionestypePackages
    tsangertypePackages
    xiaomiPackages
    ;

  inherit (microsoftPackages)
    windows-fonts
    ;

  alibaba-fonts =
    alibabaPackages.combine' "alibaba-fonts"
      (_: true);

  alimama-fonts =
    alimamaPackages.combine' "alimama-fonts"
      (_: true);

  buttaiwan-fonts =
    buttaiwanPackages.combine' "buttaiwan-fonts"
      (_: true);

  cwtex-fonts =
    cwtexPackages.combine' "cwtex-fonts"
      (_: true);

  dingtalk-fonts =
    dingtalkPackages.combine' "dingtalk-fonts"
      (_: true);

  foundertype-ctex-fonts =
    foundertypePackages.combine'
      "foundertype-ctex-fonts"
      (drv: elem drv foundertypeCtexPackages);

  foundertype-fonts =
    foundertypePackages.combine' "foundertype-fonts"
      (_: true);

  foundertype-gcu-fonts =
    foundertypePackages.combine'
      "foundertype-gcu-fonts"
      (
        drv:
        with lib.licenses;
        let
          license = drv.meta.license or null;
        in
        (license == foundertype-commercial-license)
        && (!(elem drv foundertypePaidPackages))
      );

  foundertype-gpu-fonts =
    foundertypePackages.combine'
      "foundertype-gpu-fonts"
      (
        drv:
        with lib.licenses;
        let
          license = drv.meta.license or null;
        in
        (
          (license == foundertype-commercial-license)
          || (license == foundertype-family-license)
        )
        && (!(elem drv foundertypePaidPackages))
      );

  foundertype-paid-fonts =
    foundertypePackages.combine'
      "foundertype-paid-fonts"
      (drv: elem drv foundertypePaidPackages);

  hanwang-fonts =
    hanwangPackages.combine' "hanwang-fonts"
      (_: true);

  huawei-fonts =
    huaweiPackages.combine' "huawei-fonts"
      (_: true);

  harmonyos-sans-fonts =
    huaweiPackages.combine' "harmonyos-sans-fonts"
      (drv: elem drv harmonyosSansPackages);

  harmonyos-sans-vf-fonts =
    huaweiPackages.combine' "harmonyos-sans-vf-fonts"
      (drv: elem drv harmonyosSansVfPackages);

  ichitenfont-fonts =
    ichitenfontPackages.combine' "ichitenfont-fonts"
      (_: true);

  ito-fonts = itoPackages.combine' "ito-fonts" (
    _: true
  );

  jikasei-fonts =
    jikaseiPackages.combine' "jikasei-fonts"
      (_: true);

  justfont-fonts =
    justfontPackages.combine' "justfont-fonts"
      (_: true);

  lingdong-fonts =
    lingdongPackages.combine' "lingdong-fonts"
      (_: true);

  lxgw-fonts = lxgwPackages.combine' "lxgw-fonts" (
    _: true
  );

  naver-fonts =
    naverPackages.combine' "naver-fonts"
      (_: true);

  oppo-fonts = oppoPackages.combine' "oppo-fonts" (
    _: true
  );

  tanuki-fonts =
    tanukiPackages.combine' "tanuki-fonts"
      (_: true);

  taobao-fonts =
    taobaoPackages.combine' "taobao-fonts"
      (_: true);

  tianheng-fonts =
    tianhengPackages.combine' "tianheng-fonts"
      (_: true);

  trionestype-fonts =
    trionestypePackages.combine' "trionestype-fonts"
      (_: true);

  tsangertype-fonts =
    tsangertypePackages.combine' "tsangertype-fonts"
      (_: true);

  tsangertype-gcu-fonts =
    tsangertypePackages.combine'
      "tsangertype-gcu-fonts"
      (
        drv:
        with lib.licenses;
        let
          license = drv.meta.license or null;
        in
        license == tsangertype-freefont-license
      );

  tsangertype-gpu-fonts =
    tsangertypePackages.combine'
      "tsangertype-gpu-fonts"
      (
        drv:
        with lib.licenses;
        let
          license = drv.meta.license or null;
        in
        (license == tsangertype-freefont-license)
        || (license == tsangertype-font-license)
      );

  xiaomi-fonts =
    xiaomiPackages.combine' "xiaomi-fonts"
      (_: true);

}
// import ./renamed.nix { inherit lib; }
