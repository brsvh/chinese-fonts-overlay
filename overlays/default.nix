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
    all
    elem
    escapeShellArgs
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

        mkdir -p "$out"

        for drv in ${escapeShellArgs members}; do
          ${lndir}/bin/lndir -silent "$drv" "$out"
        done

        runHook postInstall
      '';

      meta = {
        description = "Composed font collection (${pname})";

        redistributable = all (
          member:
          (member.meta.redistributable or false) == true
        ) members;
      };

      passthru = {
        fontMembers = members;
        isFontAggregate = true;
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

  chironPackages = mkVendorPackages "chiron";

  chironVfPackages = with chironPackages; [
    chiron-go-round-tc-vf
    chiron-hei-hk-vf
    chiron-sung-hk-vf
    zev-hei-tc-f
    zev-hei-tc-n
  ];

  cwtexPackages = mkVendorPackages "cwtex";

  dingtalkPackages = mkVendorPackages "dingtalk";

  foundertypePackages = mkVendorPackages "foundertype";

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

  isPaidFont =
    drv:
    (drv.chinese-fonts-overlay-pages.licenseCost
      or null
    ) == "paid";

  hanwangPackages = mkVendorPackages "hanwang";

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

  huaweiPackages = mkVendorPackages "huawei";

  huozicoolPackages = mkVendorPackages "huozicool";

  ichitenfontPackages = mkVendorPackages "ichitenfont";

  itoPackages = mkVendorPackages "ito";

  jikaseiPackages = mkVendorPackages "jikasei";

  justfontPackages = mkVendorPackages "justfont";

  kinghwaOldsongPackages = with huozicoolPackages; [
    kinghwa-oldsong
    kinghwa-oldsong-gb
    kinghwa-oldsong-gj
    kinghwa-oldsong-i
    kinghwa-oldsong-lt
    kinghwa-oldsong-mn
  ];

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
          mkMicrosoftFontDerivation = packages.builder;
        }
      );

      allPackages = removeAttrs packageScope [
        "builder"
        "callPackage"
        "mkMicrosoftFontDerivation"
        "newScope"
        "overrideScope"
        "packages"
      ];

      fontPackages = removeAttrs allPackages [
        "windows-fonts"
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

  zevacodePackages = with chironPackages; [
    zevacode-cascode
    zevacode-cascode-nf
    zevacode-casmono
    zevacode-casmono-nf
    zevacode-gima
    zevacode-gima-semicondensed
    zevacode-gimaspace-arg
    zevacode-gimaspace-arg-nf
    zevacode-gimaspace-neo
    zevacode-gimaspace-neo-nf
    zevacode-jetmono
    zevacode-jetmono-nl
  ];
in
{
  inherit
    alibabaPackages
    alimamaPackages
    buttaiwanPackages
    chironPackages
    cwtexPackages
    dingtalkPackages
    foundertypePackages
    hanwangPackages
    huaweiPackages
    huozicoolPackages
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

  alibaba-fonts = alibabaPackages.combine (_: true);

  alimama-fonts = alimamaPackages.combine (_: true);

  buttaiwan-fonts = buttaiwanPackages.combine (
    _: true
  );

  chiron-fonts = chironPackages.combine (_: true);

  chiron-vf-fonts =
    chironPackages.combine' "chiron-vf-fonts"
      (drv: elem drv chironVfPackages);

  cwtex-fonts = cwtexPackages.combine (_: true);

  dingtalk-fonts = dingtalkPackages.combine (
    _: true
  );

  foundertype-ctex-fonts =
    foundertypePackages.combine'
      "foundertype-ctex-fonts"
      (drv: elem drv foundertypeCtexPackages);

  foundertype-fonts = foundertypePackages.combine (
    _: true
  );

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
        && !(isPaidFont drv)
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
        && !(isPaidFont drv)
      );

  foundertype-paid-fonts = foundertypePackages.combine' "foundertype-paid-fonts" isPaidFont;

  hanwang-fonts = hanwangPackages.combine (_: true);

  harmonyos-sans-fonts =
    huaweiPackages.combine' "harmonyos-sans-fonts"
      (drv: elem drv harmonyosSansPackages);

  harmonyos-sans-vf-fonts =
    huaweiPackages.combine' "harmonyos-sans-vf-fonts"
      (drv: elem drv harmonyosSansVfPackages);

  huawei-fonts = huaweiPackages.combine (_: true);

  huozicool-fonts = huozicoolPackages.combine (
    _: true
  );

  ichitenfont-fonts = ichitenfontPackages.combine (
    _: true
  );

  ito-fonts = itoPackages.combine (_: true);

  jikasei-fonts = jikaseiPackages.combine (_: true);

  justfont-fonts = justfontPackages.combine (
    _: true
  );

  kinghwa-oldsong-fonts =
    huozicoolPackages.combine' "kinghwa-oldsong-fonts"
      (drv: elem drv kinghwaOldsongPackages);

  lingdong-fonts = lingdongPackages.combine (
    _: true
  );

  lxgw-fonts = lxgwPackages.combine (_: true);

  naver-fonts = naverPackages.combine (_: true);

  oppo-fonts = oppoPackages.combine (_: true);

  tanuki-fonts = tanukiPackages.combine (_: true);

  taobao-fonts = taobaoPackages.combine (_: true);

  tianheng-fonts = tianhengPackages.combine (
    _: true
  );

  trionestype-fonts = trionestypePackages.combine (
    _: true
  );

  tsangertype-fonts = tsangertypePackages.combine (
    _: true
  );

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

  xiaomi-fonts = xiaomiPackages.combine (_: true);

  zevacode-fonts =
    chironPackages.combine' "zevacode-fonts"
      (drv: elem drv zevacodePackages);
}
// import ./renamed.nix { inherit lib; }
