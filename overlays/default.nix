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
    finalAttrs: prevAttrs: {
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

  link =
    scope: pname: condition:
    stdenvNoCC.mkDerivation {
      inherit
        pname
        ;

      dontUnpack = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out

        for drv in ${concatStringsSep " " (filterDerivations condition scope)}; do
          ${lndir}/bin/lndir -silent $drv $out
        done

        runHook postInstall
      '';

      version = "0";
    };

  alibabaPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/alibaba;
      };
    in
    packages
    // {
      combine = link packages "alibaba-fonts";

      combine' = link packages;
    };

  alimamaPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/alimama;
      };
    in
    packages
    // {
      combine = link packages "alimama-fonts";

      combine' = link packages;
    };

  buttaiwanPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/buttaiwan;
      };
    in
    packages
    // {
      combine = link packages "buttaiwan-fonts";

      combine' = link packages;
    };

  dingtalkPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/dingtalk;
      };
    in
    packages
    // {
      combine = link packages "dingtalk-fonts";

      combine' = link packages;
    };

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

  foundertypePackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/foundertype;
      };
    in
    packages
    // {
      combine = link packages "foundertype-fonts";

      combine' = link packages;
    };

  foundertypePaidPackages =
    with foundertypePackages; [
      fzcuyuan
      fzlishu
      fzxiaobiaosong
      fzxiheiyi
      fzxiyuan
      fzzhunyuan
    ];

  huaweiPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/huawei;
      };
    in
    packages
    // {
      combine = link packages "huawei-fonts";

      combine' = link packages;
    };

  harmonyosSansPackages = with huaweiPackages; [
    harmonyos-sans-naskh-arabic
    harmonyos-sans-naskh-arabic-ui
  ];

  justfontPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/justfont;
      };
    in
    packages
    // {
      combine = link packages "justfont-fonts";

      combine' = link packages;
    };

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
      combine = link fontPackages "windows-fonts";

      combine' = link fontPackages;
    };

  taobaoPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/taobao;
      };
    in
    packages
    // {
      combine = link packages "taobao-fonts";

      combine' = link packages;
    };

  tianhengPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/tianheng;
      };
    in
    packages
    // {
      combine = link packages "tianheng-fonts";

      combine' = link packages;
    };

  trionestypePackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/trionestype;
      };
    in
    packages
    // {
      combine = link packages "trionestype-fonts";

      combine' = link packages;
    };

  tsangertypePackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/tsangertype;
      };
    in
    packages
    // {
      combine = link packages "tsangertype-fonts";

      combine' = link packages;
    };

  xiaomiPackages =
    let
      packages = packagesFromDirectoryRecursive {
        inherit (final)
          callPackage
          newScope
          ;

        directory = projectRoot + /packages/xiaomi;
      };
    in
    packages
    // {
      combine = link packages "xiaomi-fonts";

      combine' = link packages;
    };
in
{
  inherit
    alibabaPackages
    alimamaPackages
    buttaiwanPackages
    dingtalkPackages
    foundertypePackages
    huaweiPackages
    justfontPackages
    lib
    microsoftPackages
    taobaoPackages
    tianhengPackages
    trionestypePackages
    tsangertypePackages
    xiaomiPackages
    ;

  alibaba-fonts =
    alibabaPackages.combine' "alibaba-fonts"
      (_: true);

  alibabaFonts = {
    puhuiti-2 = throw ''
      alibabaFonts.puhuiti-2 has been renamed to
      alibabaPackages.puhuiti2.
    '';

    puhuiti-3 = throw ''
      alibabaFonts.puhuiti-3 has been renamed to
      alibabaPackages.puhuiti3.
    '';
  };

  alimama-fonts =
    alimamaPackages.combine' "alimama-fonts"
      (_: true);

  buttaiwan-fonts =
    buttaiwanPackages.combine' "buttaiwan-fonts"
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

  huawei-fonts =
    huaweiPackages.combine' "huawei-fonts"
      (_: true);

  harmonyos-sans-fonts =
    huaweiPackages.combine' "harmonyos-sans-fonts"
      (drv: elem drv harmonyosSansPackages);

  justfont-fonts =
    justfontPackages.combine' "justfont-fonts"
      (_: true);

  foundertypeFonts = {
    FZFSK = throw ''
      foundertypeFonts.FZFSK has been renamed to
      foundertypePackages.fzfangsong.
    '';

    FZHTK = throw ''
      foundertypeFonts.FZHTK has been renamed to
      foundertypePackages.fzheiti.
    '';

    FZKTK = throw ''
      foundertypeFonts.FZKTK has been renamed to
      foundertypePackages.fzkaiti.
    '';

    FZLSK = throw ''
      foundertypeFonts.FZLSK has been renamed to
      foundertypePackages.fzlishu.
    '';

    FZSSK = throw ''
      foundertypeFonts.FZSSK has been renamed to
      foundertypePackages.fzshusong.
    '';

    FZXBSK = throw ''
      foundertypeFonts.FZXBSK has been renamed to
      foundertypePackages.fzxiaobiaosong.
    '';

    FZXH1K = throw ''
      foundertypeFonts.FZXH1K has been renamed to
      foundertypePackages.fzxiheiyi.
    '';

    FZY1K = throw ''
      foundertypeFonts.FZY1K has been renamed to
      foundertypePackages.fzxiyuan.
    '';

    FZY3K = throw ''
      foundertypeFonts.FZY3K has been renamed to
      foundertypePackages.fzzhunyuan.
    '';

    FZY4K = throw ''
      foundertypeFonts.FZY4K has been renamed to
      foundertypePackages.fzcuyuan.
    '';
  };

  taobao-fonts =
    taobaoPackages.combine' "taobao-fonts"
      (_: true);

  TH-fonts = throw ''
    TH-fonts has been renamed to tianheng-fonts.
  '';

  THFonts = {
    Hak = throw ''
      THFonts.Hak has been renamed to
      tianhengPackages.hak.
    '';

    Joeng = throw ''
      THFonts.Joeng has been renamed to
      tianhengPackages.joeng.
    '';

    Khaai-P = throw ''
      THFonts.Khaai-P has been renamed to
      tianhengPackages.khaai-p.
    '';

    Khaai-T = throw ''
      THFonts.Khaai-T has been renamed to
      tianhengPackages.khaai-t.
    '';

    Ming = throw ''
      THFonts.Ming has been renamed to
      tianhengPackages.ming.
    '';

    Sung-P = throw ''
      THFonts.Sung-P has been renamed to
      tianhengPackages.sung-p.
    '';

    Sung-T = throw ''
      THFonts.Sung-T has been renamed to
      tianhengPackages.sung-t.
    '';

    Sy = throw ''
      THFonts.Sy has been renamed to
      tianhengPackages.sy.
    '';

    Tshyn = throw ''
      THFonts.Tshyn has been renamed to
      tianhengPackages.tshyn.
    '';
  };

  tianheng-fonts =
    tianhengPackages.combine' "tianheng-fonts"
      (_: true);

  trionestype-fonts =
    trionestypePackages.combine' "trionestype-fonts"
      (_: true);

  trionestypeFonts = {
    ZhuqueFangsong = throw ''
      trionestypeFonts.ZhuqueFangsong has been renamed to
      trionestypePackages.zhuque-fangsong.
    '';
  };

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
        (
          (license == tsangertype-freefont-license)
          || (license == tsangertype-font-license)
        )
      );

  xiaomi-fonts =
    xiaomiPackages.combine' "xiaomi-fonts"
      (_: true);

  tsangertypeFonts = {
    aidekunkun = throw ''
      tsangertypeFonts.aidekunkun has been renamed to
      tsangertypePackages.tsangeradkkt.
    '';

    aiminxiaokai = throw ''
      tsangertypeFonts.aiminxiaokai has been renamed to
      tsangertypePackages.tsangeramxk.
    '';

    aiminxingkai = throw ''
      tsangertypeFonts.aiminxingkai has been renamed to
      tsangertypePackages.tsangeramxingkai.
    '';

    aiminxingshu = throw ''
      tsangertypeFonts.aiminxingshu has been renamed to
      tsangertypePackages.tsangeramxs.
    '';

    ainimengmengda = throw ''
      tsangertypeFonts.ainimengmengda has been renamed to
      tsangertypePackages.tsangeranmmdt.
    '';

    aiqinglianxisheng = throw ''
      tsangertypeFonts.aiqinglianxisheng has been renamed to
      tsangertypePackages.tsangeraqlxs.
    '';

    babilong = throw ''
      tsangertypeFonts.babilong has been renamed to
      tsangertypePackages.tsangerbblt.
    '';

    bailing-w01 = throw ''
      tsangertypeFonts.bailing-w01 has been renamed to
      tsangertypePackages.tsangerblgl.
    '';

    bailing-w02 = throw ''
      tsangertypeFonts.bailing-w02 has been renamed to
      tsangertypePackages.tsangerblgl.
    '';

    bailing-w03 = throw ''
      tsangertypeFonts.bailing-w03 has been renamed to
      tsangertypePackages.tsangerblgl.
    '';

    bailing-w04 = throw ''
      tsangertypeFonts.bailing-w04 has been renamed to
      tsangertypePackages.tsangerblgl.
    '';

    bailing-w05 = throw ''
      tsangertypeFonts.bailing-w05 has been renamed to
      tsangertypePackages.tsangerblgl.
    '';

    banghei = throw ''
      tsangertypeFonts.banghei has been renamed to
      tsangertypePackages.tsangerbanghei.
    '';

    bantangshouzha = throw ''
      tsangertypeFonts.bantangshouzha has been renamed to
      tsangertypePackages.tsangerbtsz.
    '';

    benmiaozaici = throw ''
      tsangertypeFonts.benmiaozaici has been renamed to
      tsangertypePackages.tsangerbmzct.
    '';

    cangermuxi = throw ''
      tsangertypeFonts.cangermuxi has been renamed to
      tsangertypePackages.tsangermxt.
    '';

    caolulinshouji = throw ''
      tsangertypeFonts.caolulinshouji has been renamed to
      tsangertypePackages.tsangercllsj.
    '';

    caozhebinjunxiukaishu = throw ''
      tsangertypeFonts.caozhebinjunxiukaishu has been renamed to
      tsangertypePackages.tsangerczbjxks.
    '';

    caozhebinjunxiukaishu-bold = throw ''
      tsangertypeFonts.caozhebinjunxiukaishu-bold has been renamed to
      tsangertypePackages.tsangerczbjxks.
    '';

    caozhebinkaishu = throw ''
      tsangertypeFonts.caozhebinkaishu has been renamed to
      tsangertypePackages.tsangerczbksjf.
    '';

    caozhebinkaishu-bold = throw ''
      tsangertypeFonts.caozhebinkaishu-bold has been renamed to
      tsangertypePackages.tsangerczbksjf.
    '';

    caozhebinlingyunkaishu = throw ''
      tsangertypeFonts.caozhebinlingyunkaishu has been renamed to
      tsangertypePackages.tsangerczblyks.
    '';

    caozhebinlingyunkaishu-bold = throw ''
      tsangertypeFonts.caozhebinlingyunkaishu-bold has been renamed to
      tsangertypePackages.tsangerczblyks.
    '';

    caozhebinxingkai = throw ''
      tsangertypeFonts.caozhebinxingkai has been renamed to
      tsangertypePackages.tsangerczbxkjf.
    '';

    chengshishangkongdefanxing = throw ''
      tsangertypeFonts.chengshishangkongdefanxing has been renamed to
      tsangertypePackages.tsangercsskdfxt.
    '';

    chuangyi-w01 = throw ''
      tsangertypeFonts.chuangyi-w01 has been renamed to
      tsangertypePackages.tsangerchuangyi.
    '';

    chuangyi-w02 = throw ''
      tsangertypeFonts.chuangyi-w02 has been renamed to
      tsangertypePackages.tsangerchuangyi.
    '';

    chuangyi-w03 = throw ''
      tsangertypeFonts.chuangyi-w03 has been renamed to
      tsangertypePackages.tsangerchuangyi.
    '';

    chunfeng = throw ''
      tsangertypeFonts.chunfeng has been renamed to
      tsangertypePackages.tsangerchunfeng.
    '';

    chuyu = throw ''
      tsangertypeFonts.chuyu has been renamed to
      tsangertypePackages.tsangercyt.
    '';

    daimengxiaomutou = throw ''
      tsangertypeFonts.daimengxiaomutou has been renamed to
      tsangertypePackages.tsangerdmxmtt.
    '';

    dainiushouxie = throw ''
      tsangertypeFonts.dainiushouxie has been renamed to
      tsangertypePackages.tsangerdnsxt.
    '';

    daji = throw ''
      tsangertypeFonts.daji has been renamed to
      tsangertypePackages.tsangerdajiti.
    '';

    damanman-w01 = throw ''
      tsangertypeFonts.damanman-w01 has been renamed to
      tsangertypePackages.tsangerdmmt.
    '';

    damanman-w02 = throw ''
      tsangertypeFonts.damanman-w02 has been renamed to
      tsangertypePackages.tsangerdmmt.
    '';

    damanman-w03 = throw ''
      tsangertypeFonts.damanman-w03 has been renamed to
      tsangertypePackages.tsangerdmmt.
    '';

    damanman-w04 = throw ''
      tsangertypeFonts.damanman-w04 has been renamed to
      tsangertypePackages.tsangerdmmt.
    '';

    damanman-w05 = throw ''
      tsangertypeFonts.damanman-w05 has been renamed to
      tsangertypePackages.tsangerdmmt.
    '';

    daofengzhanshi = throw ''
      tsangertypeFonts.daofengzhanshi has been renamed to
      tsangertypePackages.tsangerdfzst.
    '';

    daofengzhanshi-bold = throw ''
      tsangertypeFonts.daofengzhanshi-bold has been renamed to
      tsangertypePackages.tsangerdfzst.
    '';

    dianshichengjin = throw ''
      tsangertypeFonts.dianshichengjin has been renamed to
      tsangertypePackages.tsangerdscjt.
    '';

    diewu = throw ''
      tsangertypeFonts.diewu has been renamed to
      tsangertypePackages.tsangerdwt.
    '';

    diyiyanaishangni = throw ''
      tsangertypeFonts.diyiyanaishangni has been renamed to
      tsangertypePackages.tsangersangqi.
    '';

    dubai = throw ''
      tsangertypeFonts.dubai has been renamed to
      tsangertypePackages.tsangerdubaiti.
    '';

    dudu-w01 = throw ''
      tsangertypeFonts.dudu-w01 has been renamed to
      tsangertypePackages.tsangerddt.
    '';

    dudu-w02 = throw ''
      tsangertypeFonts.dudu-w02 has been renamed to
      tsangertypePackages.tsangerddt.
    '';

    dudu-w03 = throw ''
      tsangertypeFonts.dudu-w03 has been renamed to
      tsangertypePackages.tsangerddt.
    '';

    dudu-w04 = throw ''
      tsangertypeFonts.dudu-w04 has been renamed to
      tsangertypePackages.tsangerddt.
    '';

    fanghei = throw ''
      tsangertypeFonts.fanghei has been renamed to
      tsangertypePackages.tsangerfanghei.
    '';

    feibai-w01 = throw ''
      tsangertypeFonts.feibai-w01 has been renamed to
      tsangertypePackages.tsangerfeibai.
    '';

    feibai-w02 = throw ''
      tsangertypeFonts.feibai-w02 has been renamed to
      tsangertypePackages.tsangerfeibai.
    '';

    feibai-w03 = throw ''
      tsangertypeFonts.feibai-w03 has been renamed to
      tsangertypePackages.tsangerfeibai.
    '';

    feibai-w04 = throw ''
      tsangertypeFonts.feibai-w04 has been renamed to
      tsangertypePackages.tsangerfeibai.
    '';

    feibai-w05 = throw ''
      tsangertypeFonts.feibai-w05 has been renamed to
      tsangertypePackages.tsangerfeibai.
    '';

    feifei-w01 = throw ''
      tsangertypeFonts.feifei-w01 has been renamed to
      tsangertypePackages.tsangerfft.
    '';

    feifei-w02 = throw ''
      tsangertypeFonts.feifei-w02 has been renamed to
      tsangertypePackages.tsangerfft.
    '';

    feifei-w03 = throw ''
      tsangertypeFonts.feifei-w03 has been renamed to
      tsangertypePackages.tsangerfft.
    '';

    feifei-w04 = throw ''
      tsangertypeFonts.feifei-w04 has been renamed to
      tsangertypePackages.tsangerfft.
    '';

    feigexiaosaxingshu = throw ''
      tsangertypeFonts.feigexiaosaxingshu has been renamed to
      tsangertypePackages.tsangerfgxsxst.
    '';

    feiteng = throw ''
      tsangertypeFonts.feiteng has been renamed to
      tsangertypePackages.tsangerftt.
    '';

    fengerchui = throw ''
      tsangertypeFonts.fengerchui has been renamed to
      tsangertypePackages.tsangerfec.
    '';

    fenghei = throw ''
      tsangertypeFonts.fenghei has been renamed to
      tsangertypePackages.tsangerfenghei.
    '';

    fengwujiutian-w01 = throw ''
      tsangertypeFonts.fengwujiutian-w01 has been renamed to
      tsangertypePackages.tsangerfwjt.
    '';

    fengwujiutian-w02 = throw ''
      tsangertypeFonts.fengwujiutian-w02 has been renamed to
      tsangertypePackages.tsangerfwjt.
    '';

    fengwujiutian-w03 = throw ''
      tsangertypeFonts.fengwujiutian-w03 has been renamed to
      tsangertypePackages.tsangerfwjt.
    '';

    fengwujiutian-w04 = throw ''
      tsangertypeFonts.fengwujiutian-w04 has been renamed to
      tsangertypePackages.tsangerfwjt.
    '';

    fengwujiutian-w05 = throw ''
      tsangertypeFonts.fengwujiutian-w05 has been renamed to
      tsangertypePackages.tsangerfwjt.
    '';

    fengwujiutian-w06 = throw ''
      tsangertypeFonts.fengwujiutian-w06 has been renamed to
      tsangertypePackages.tsangerfwjt.
    '';

    fengyun-w01 = throw ''
      tsangertypeFonts.fengyun-w01 has been renamed to
      tsangertypePackages.tsangerfyt.
    '';

    fengyun-w02 = throw ''
      tsangertypeFonts.fengyun-w02 has been renamed to
      tsangertypePackages.tsangerfyt.
    '';

    fengyun-w03 = throw ''
      tsangertypeFonts.fengyun-w03 has been renamed to
      tsangertypePackages.tsangerfyt.
    '';

    fengyun-w04 = throw ''
      tsangertypeFonts.fengyun-w04 has been renamed to
      tsangertypePackages.tsangerfyt.
    '';

    fengyun-w05 = throw ''
      tsangertypeFonts.fengyun-w05 has been renamed to
      tsangertypePackages.tsangerfyt.
    '';

    fengyun-w06 = throw ''
      tsangertypeFonts.fengyun-w06 has been renamed to
      tsangertypePackages.tsangerfyt.
    '';

    fengyun-w07 = throw ''
      tsangertypeFonts.fengyun-w07 has been renamed to
      tsangertypePackages.tsangerfyt.
    '';

    gexingtuya = throw ''
      tsangertypeFonts.gexingtuya has been renamed to
      tsangertypePackages.tsangergxtyt.
    '';

    guateng = throw ''
      tsangertypeFonts.guateng has been renamed to
      tsangertypePackages.tsangergtt.
    '';

    gufengkaishu = throw ''
      tsangertypeFonts.gufengkaishu has been renamed to
      tsangertypePackages.tsangergfks.
    '';

    gufengxingshu = throw ''
      tsangertypeFonts.gufengxingshu has been renamed to
      tsangertypePackages.tsangergfxs.
    '';

    guli-w01 = throw ''
      tsangertypeFonts.guli-w01 has been renamed to
      tsangertypePackages.tsangerguli.
    '';

    guli-w02 = throw ''
      tsangertypeFonts.guli-w02 has been renamed to
      tsangertypePackages.tsangerguli.
    '';

    guli-w03 = throw ''
      tsangertypeFonts.guli-w03 has been renamed to
      tsangertypePackages.tsangerguli.
    '';

    guli-w04 = throw ''
      tsangertypeFonts.guli-w04 has been renamed to
      tsangertypePackages.tsangerguli.
    '';

    guli-w05 = throw ''
      tsangertypeFonts.guli-w05 has been renamed to
      tsangertypePackages.tsangerguli.
    '';

    guodongxixi = throw ''
      tsangertypeFonts.guodongxixi has been renamed to
      tsangertypePackages.tsangergdxxt.
    '';

    guyun = throw ''
      tsangertypeFonts.guyun has been renamed to
      tsangertypePackages.tsangerguyun.
    '';

    haloutuxiansheng = throw ''
      tsangertypeFonts.haloutuxiansheng has been renamed to
      tsangertypePackages.tsangerhltxst.
    '';

    hanshan = throw ''
      tsangertypeFonts.hanshan has been renamed to
      tsangertypePackages.tsangerhst.
    '';

    hefeng = throw ''
      tsangertypeFonts.hefeng has been renamed to
      tsangertypePackages.tsangerhft.
    '';

    huaxin = throw ''
      tsangertypeFonts.huaxin has been renamed to
      tsangertypePackages.tsangerhuaxinti.
    '';

    huayu = throw ''
      tsangertypeFonts.huayu has been renamed to
      tsangertypePackages.tsangerhby.
    '';

    jiaotangmaqiduo = throw ''
      tsangertypeFonts.jiaotangmaqiduo has been renamed to
      tsangertypePackages.tsangerjtmqdt.
    '';

    jiaxuan = throw ''
      tsangertypeFonts.jiaxuan has been renamed to
      tsangertypePackages.tsangerjxt.
    '';

    jiekou = throw ''
      tsangertypeFonts.jiekou has been renamed to
      tsangertypePackages.tsangerjkt.
    '';

    jiemo = throw ''
      tsangertypeFonts.jiemo has been renamed to
      tsangertypePackages.tsangerjmt.
    '';

    jingya = throw ''
      tsangertypeFonts.jingya has been renamed to
      tsangertypePackages.tsangerjyt.
    '';

    jinkai-01-w01 = throw ''
      tsangertypeFonts.jinkai-01-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-01-w02 = throw ''
      tsangertypeFonts.jinkai-01-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-01-w03 = throw ''
      tsangertypeFonts.jinkai-01-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-01-w04 = throw ''
      tsangertypeFonts.jinkai-01-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-01-w05 = throw ''
      tsangertypeFonts.jinkai-01-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-02-w01 = throw ''
      tsangertypeFonts.jinkai-02-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-02-w02 = throw ''
      tsangertypeFonts.jinkai-02-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-02-w03 = throw ''
      tsangertypeFonts.jinkai-02-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-02-w04 = throw ''
      tsangertypeFonts.jinkai-02-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-02-w05 = throw ''
      tsangertypeFonts.jinkai-02-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-03-w01 = throw ''
      tsangertypeFonts.jinkai-03-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-03-w02 = throw ''
      tsangertypeFonts.jinkai-03-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-03-w03 = throw ''
      tsangertypeFonts.jinkai-03-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-03-w04 = throw ''
      tsangertypeFonts.jinkai-03-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-03-w05 = throw ''
      tsangertypeFonts.jinkai-03-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-04-w01 = throw ''
      tsangertypeFonts.jinkai-04-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-04-w02 = throw ''
      tsangertypeFonts.jinkai-04-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-04-w03 = throw ''
      tsangertypeFonts.jinkai-04-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-04-w04 = throw ''
      tsangertypeFonts.jinkai-04-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-04-w05 = throw ''
      tsangertypeFonts.jinkai-04-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-05-w01 = throw ''
      tsangertypeFonts.jinkai-05-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-05-w02 = throw ''
      tsangertypeFonts.jinkai-05-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-05-w03 = throw ''
      tsangertypeFonts.jinkai-05-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-05-w04 = throw ''
      tsangertypeFonts.jinkai-05-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai-05-w05 = throw ''
      tsangertypeFonts.jinkai-05-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai01-w01 = throw ''
      tsangertypeFonts.jinkai01-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai01-w02 = throw ''
      tsangertypeFonts.jinkai01-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai01-w03 = throw ''
      tsangertypeFonts.jinkai01-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai01-w04 = throw ''
      tsangertypeFonts.jinkai01-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai01-w05 = throw ''
      tsangertypeFonts.jinkai01-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai02-w01 = throw ''
      tsangertypeFonts.jinkai02-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai02-w02 = throw ''
      tsangertypeFonts.jinkai02-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai02-w03 = throw ''
      tsangertypeFonts.jinkai02-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai02-w04 = throw ''
      tsangertypeFonts.jinkai02-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai02-w05 = throw ''
      tsangertypeFonts.jinkai02-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai03-w01 = throw ''
      tsangertypeFonts.jinkai03-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai03-w02 = throw ''
      tsangertypeFonts.jinkai03-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai03-w03 = throw ''
      tsangertypeFonts.jinkai03-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai03-w04 = throw ''
      tsangertypeFonts.jinkai03-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai03-w05 = throw ''
      tsangertypeFonts.jinkai03-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai04-w01 = throw ''
      tsangertypeFonts.jinkai04-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai04-w02 = throw ''
      tsangertypeFonts.jinkai04-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai04-w03 = throw ''
      tsangertypeFonts.jinkai04-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai04-w04 = throw ''
      tsangertypeFonts.jinkai04-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai04-w05 = throw ''
      tsangertypeFonts.jinkai04-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai05-w01 = throw ''
      tsangertypeFonts.jinkai05-w01 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai05-w02 = throw ''
      tsangertypeFonts.jinkai05-w02 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai05-w03 = throw ''
      tsangertypeFonts.jinkai05-w03 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai05-w04 = throw ''
      tsangertypeFonts.jinkai05-w04 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinkai05-w05 = throw ''
      tsangertypeFonts.jinkai05-w05 has been renamed to
      tsangertypePackages.tsangerjinkai.
    '';

    jinshirongyao = throw ''
      tsangertypeFonts.jinshirongyao has been renamed to
      tsangertypePackages.tsangerjsryt.
    '';

    jundongkaishu = throw ''
      tsangertypeFonts.jundongkaishu has been renamed to
      tsangertypePackages.tsangerjdks.
    '';

    jundongxingshu = throw ''
      tsangertypeFonts.jundongxingshu has been renamed to
      tsangertypePackages.tsangerjdxs.
    '';

    juzhenchangfang = throw ''
      tsangertypeFonts.juzhenchangfang has been renamed to
      tsangertypePackages.tsangerjzcf.
    '';

    juziwei = throw ''
      tsangertypeFonts.juziwei has been renamed to
      tsangertypePackages.tsangerjzw.
    '';

    keke = throw ''
      tsangertypeFonts.keke has been renamed to
      tsangertypePackages.tsangerkeketi.
    '';

    konglukaishu = throw ''
      tsangertypeFonts.konglukaishu has been renamed to
      tsangertypePackages.tsangerklks.
    '';

    kuhei = throw ''
      tsangertypeFonts.kuhei has been renamed to
      tsangertypePackages.tsangerkuhei.
    '';

    lankai = throw ''
      tsangertypeFonts.lankai has been renamed to
      tsangertypePackages.tsangerlankai.
    '';

    leizhenhanfeng = throw ''
      tsangertypeFonts.leizhenhanfeng has been renamed to
      tsangertypePackages.tsangerlzhft.
    '';

    lekeke = throw ''
      tsangertypeFonts.lekeke has been renamed to
      tsangertypePackages.tsangerlkkt.
    '';

    lelebiji = throw ''
      tsangertypeFonts.lelebiji has been renamed to
      tsangertypePackages.tsangerllbjt.
    '';

    lezhi = throw ''
      tsangertypeFonts.lezhi has been renamed to
      tsangertypePackages.tsangerlzt.
    '';

    lianaibiji = throw ''
      tsangertypeFonts.lianaibiji has been renamed to
      tsangertypePackages.tsangerlabjt.
    '';

    lifei = throw ''
      tsangertypeFonts.lifei has been renamed to
      tsangertypePackages.tsangerlifeiti.
    '';

    linggang-w01 = throw ''
      tsangertypeFonts.linggang-w01 has been renamed to
      tsangertypePackages.tsangerlinggang.
    '';

    linggang-w02 = throw ''
      tsangertypeFonts.linggang-w02 has been renamed to
      tsangertypePackages.tsangerlinggang.
    '';

    linggang-w03 = throw ''
      tsangertypeFonts.linggang-w03 has been renamed to
      tsangertypePackages.tsangerlinggang.
    '';

    linggang-w04 = throw ''
      tsangertypeFonts.linggang-w04 has been renamed to
      tsangertypePackages.tsangerlinggang.
    '';

    linggang-w05 = throw ''
      tsangertypeFonts.linggang-w05 has been renamed to
      tsangertypePackages.tsangerlinggang.
    '';

    lingyun = throw ''
      tsangertypeFonts.lingyun has been renamed to
      tsangertypePackages.tsangerlyt.
    '';

    lishi = throw ''
      tsangertypeFonts.lishi has been renamed to
      tsangertypePackages.tsangerlishiti.
    '';

    liyuan = throw ''
      tsangertypeFonts.liyuan has been renamed to
      tsangertypePackages.tsangerliyuan.
    '';

    manmiao = throw ''
      tsangertypeFonts.manmiao has been renamed to
      tsangertypePackages.tsangermanmiao.
    '';

    maobohe = throw ''
      tsangertypeFonts.maobohe has been renamed to
      tsangertypePackages.tsangermbht.
    '';

    meixin-w01 = throw ''
      tsangertypeFonts.meixin-w01 has been renamed to
      tsangertypePackages.tsangermeixin.
    '';

    meixin-w02 = throw ''
      tsangertypeFonts.meixin-w02 has been renamed to
      tsangertypePackages.tsangermeixin.
    '';

    mengbaokeji = throw ''
      tsangertypeFonts.mengbaokeji has been renamed to
      tsangertypePackages.tsangermbkjt.
    '';

    mengdaimiaowei = throw ''
      tsangertypeFonts.mengdaimiaowei has been renamed to
      tsangertypePackages.tsangermdmwt.
    '';

    mengdie = throw ''
      tsangertypeFonts.mengdie has been renamed to
      tsangertypePackages.tsangermengdie.
    '';

    mengduoduo = throw ''
      tsangertypeFonts.mengduoduo has been renamed to
      tsangertypePackages.tsangermddt.
    '';

    mengmengdaxiaodouzi = throw ''
      tsangertypeFonts.mengmengdaxiaodouzi has been renamed to
      tsangertypePackages.tsangermmdxdzt.
    '';

    mengmiaojiang = throw ''
      tsangertypeFonts.mengmiaojiang has been renamed to
      tsangertypePackages.tsangermmjt.
    '';

    mengtonglishu = throw ''
      tsangertypeFonts.mengtonglishu has been renamed to
      tsangertypePackages.tsangermtls.
    '';

    mengxingdelibie = throw ''
      tsangertypeFonts.mengxingdelibie has been renamed to
      tsangertypePackages.tsangermxlbt.
    '';

    minghei-w01 = throw ''
      tsangertypeFonts.minghei-w01 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    minghei-w02 = throw ''
      tsangertypeFonts.minghei-w02 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    minghei-w03 = throw ''
      tsangertypeFonts.minghei-w03 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    minghei-w04 = throw ''
      tsangertypeFonts.minghei-w04 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    minghei-w05 = throw ''
      tsangertypeFonts.minghei-w05 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    minghei-w06 = throw ''
      tsangertypeFonts.minghei-w06 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    minghei-w07 = throw ''
      tsangertypeFonts.minghei-w07 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    minghei-w08 = throw ''
      tsangertypeFonts.minghei-w08 has been renamed to
      tsangertypePackages.tsangerminghei.
    '';

    mingkai-w01 = throw ''
      tsangertypeFonts.mingkai-w01 has been renamed to
      tsangertypePackages.tsangermingkai.
    '';

    mingkai-w02 = throw ''
      tsangertypeFonts.mingkai-w02 has been renamed to
      tsangertypePackages.tsangermingkai.
    '';

    mingkai-w03 = throw ''
      tsangertypeFonts.mingkai-w03 has been renamed to
      tsangertypePackages.tsangermingkai.
    '';

    mingkai-w04 = throw ''
      tsangertypeFonts.mingkai-w04 has been renamed to
      tsangertypePackages.tsangermingkai.
    '';

    mingyue = throw ''
      tsangertypeFonts.mingyue has been renamed to
      tsangertypePackages.tsangermingyueti.
    '';

    mizhiguo = throw ''
      tsangertypeFonts.mizhiguo has been renamed to
      tsangertypePackages.tsangermzgt.
    '';

    mocha = throw ''
      tsangertypeFonts.mocha has been renamed to
      tsangertypePackages.tsangermochati.
    '';

    nihaoshiguang = throw ''
      tsangertypeFonts.nihaoshiguang has been renamed to
      tsangertypePackages.tsangernhsgt.
    '';

    nishiwodequanshijie = throw ''
      tsangertypeFonts.nishiwodequanshijie has been renamed to
      tsangertypePackages.tsangernswdqsj.
    '';

    nishiwoweiyi = throw ''
      tsangertypeFonts.nishiwoweiyi has been renamed to
      tsangertypePackages.tsangernswdwy.
    '';

    nuannanshouzha = throw ''
      tsangertypeFonts.nuannanshouzha has been renamed to
      tsangertypePackages.tsangernnszt.
    '';

    nuanxin = throw ''
      tsangertypeFonts.nuanxin has been renamed to
      tsangertypePackages.tsangernxt.
    '';

    nvwang = throw ''
      tsangertypeFonts.nvwang has been renamed to
      tsangertypePackages.tsangernwt.
    '';

    peiban = throw ''
      tsangertypeFonts.peiban has been renamed to
      tsangertypePackages.tsangerpbt.
    '';

    piaomiao = throw ''
      tsangertypeFonts.piaomiao has been renamed to
      tsangertypePackages.tsangerpmt.
    '';

    qiaole-w01 = throw ''
      tsangertypeFonts.qiaole-w01 has been renamed to
      tsangertypePackages.tsangerqiaoleti.
    '';

    qiaole-w02 = throw ''
      tsangertypeFonts.qiaole-w02 has been renamed to
      tsangertypePackages.tsangerqiaoleti.
    '';

    qiaole-w03 = throw ''
      tsangertypeFonts.qiaole-w03 has been renamed to
      tsangertypePackages.tsangerqiaoleti.
    '';

    qiaole-w04 = throw ''
      tsangertypeFonts.qiaole-w04 has been renamed to
      tsangertypePackages.tsangerqiaoleti.
    '';

    qiaole-w05 = throw ''
      tsangertypeFonts.qiaole-w05 has been renamed to
      tsangertypePackages.tsangerqiaoleti.
    '';

    qiedoudou = throw ''
      tsangertypeFonts.qiedoudou has been renamed to
      tsangertypePackages.tsangerqeddt.
    '';

    qiming = throw ''
      tsangertypeFonts.qiming has been renamed to
      tsangertypePackages.tsangergqimingti.
    '';

    qingchunyiniweiming = throw ''
      tsangertypeFonts.qingchunyiniweiming has been renamed to
      tsangertypePackages.tsangerqcynwmt.
    '';

    qingfeng = throw ''
      tsangertypeFonts.qingfeng has been renamed to
      tsangertypePackages.tsangerqft.
    '';

    qingfengxieyang = throw ''
      tsangertypeFonts.qingfengxieyang has been renamed to
      tsangertypePackages.tsangerqfxyt.
    '';

    qinghe-w01 = throw ''
      tsangertypeFonts.qinghe-w01 has been renamed to
      tsangertypePackages.tsangerqhtgl.
    '';

    qinghe-w02 = throw ''
      tsangertypeFonts.qinghe-w02 has been renamed to
      tsangertypePackages.tsangerqhtgl.
    '';

    qinghe-w03 = throw ''
      tsangertypeFonts.qinghe-w03 has been renamed to
      tsangertypePackages.tsangerqhtgl.
    '';

    qinghe-w04 = throw ''
      tsangertypeFonts.qinghe-w04 has been renamed to
      tsangertypePackages.tsangerqhtgl.
    '';

    qinghe-w05 = throw ''
      tsangertypeFonts.qinghe-w05 has been renamed to
      tsangertypePackages.tsangerqhtgl.
    '';

    qinghuan = throw ''
      tsangertypeFonts.qinghuan has been renamed to
      tsangertypePackages.tsangerqht.
    '';

    qingji = throw ''
      tsangertypeFonts.qingji has been renamed to
      tsangertypePackages.tsangerqingjiti.
    '';

    qingmei = throw ''
      tsangertypeFonts.qingmei has been renamed to
      tsangertypePackages.tsangerqmt.
    '';

    qingning = throw ''
      tsangertypeFonts.qingning has been renamed to
      tsangertypePackages.tsangerqnt.
    '';

    qingqiuxiaojiu = throw ''
      tsangertypeFonts.qingqiuxiaojiu has been renamed to
      tsangertypePackages.tsangerqqxj.
    '';

    qingque = throw ''
      tsangertypeFonts.qingque has been renamed to
      tsangertypePackages.tsangerqqt.
    '';

    qingsong = throw ''
      tsangertypeFonts.qingsong has been renamed to
      tsangertypePackages.tsangerqingsongti.
    '';

    qingxin = throw ''
      tsangertypeFonts.qingxin has been renamed to
      tsangertypePackages.tsangerqxt.
    '';

    qingya-fang = throw ''
      tsangertypeFonts.qingya-fang has been renamed to
      tsangertypePackages.tsangerqingya.
    '';

    qingya-yuan = throw ''
      tsangertypeFonts.qingya-yuan has been renamed to
      tsangertypePackages.tsangerqingya.
    '';

    qingyou = throw ''
      tsangertypeFonts.qingyou has been renamed to
      tsangertypePackages.tsangerqingyou.
    '';

    qinqinmeizhuang = throw ''
      tsangertypeFonts.qinqinmeizhuang has been renamed to
      tsangertypePackages.tsangerqqmzt.
    '';

    qiuyue = throw ''
      tsangertypeFonts.qiuyue has been renamed to
      tsangertypePackages.tsangerqyt.
    '';

    quancunzuikeai = throw ''
      tsangertypeFonts.quancunzuikeai has been renamed to
      tsangertypePackages.tsangerqczka.
    '';

    quhei = throw ''
      tsangertypeFonts.quhei has been renamed to
      tsangertypePackages.tsangerquhei.
    '';

    rouhei = throw ''
      tsangertypeFonts.rouhei has been renamed to
      tsangertypePackages.tsangerrouhei.
    '';

    ruihei = throw ''
      tsangertypeFonts.ruihei has been renamed to
      tsangertypePackages.tsangerruihei.
    '';

    runhei-w01 = throw ''
      tsangertypeFonts.runhei-w01 has been renamed to
      tsangertypePackages.tsangerrunhei.
    '';

    runhei-w02 = throw ''
      tsangertypeFonts.runhei-w02 has been renamed to
      tsangertypePackages.tsangerrunhei.
    '';

    runhei-w03 = throw ''
      tsangertypeFonts.runhei-w03 has been renamed to
      tsangertypePackages.tsangerrunhei.
    '';

    shangshanruoshui = throw ''
      tsangertypeFonts.shangshanruoshui has been renamed to
      tsangertypePackages.tsangerssrs.
    '';

    shenniaoxinshengchuangyi = throw ''
      tsangertypeFonts.shenniaoxinshengchuangyi has been renamed to
      tsangertypePackages.tsangersnxscyt.
    '';

    shenqidedoudou = throw ''
      tsangertypeFonts.shenqidedoudou has been renamed to
      tsangertypePackages.tsangersqdddt.
    '';

    shuhei = throw ''
      tsangertypeFonts.shuhei has been renamed to
      tsangertypePackages.tsangershuhei.
    '';

    shuyuan-w01 = throw ''
      tsangertypeFonts.shuyuan-w01 has been renamed to
      tsangertypePackages.tsangershuyuant.
    '';

    shuyuan-w02 = throw ''
      tsangertypeFonts.shuyuan-w02 has been renamed to
      tsangertypePackages.tsangershuyuant.
    '';

    shuyuan-w03 = throw ''
      tsangertypeFonts.shuyuan-w03 has been renamed to
      tsangertypePackages.tsangershuyuant.
    '';

    shuyuan-w04 = throw ''
      tsangertypeFonts.shuyuan-w04 has been renamed to
      tsangertypePackages.tsangershuyuant.
    '';

    shuyuan-w05 = throw ''
      tsangertypeFonts.shuyuan-w05 has been renamed to
      tsangertypePackages.tsangershuyuant.
    '';

    sirou = throw ''
      tsangertypeFonts.sirou has been renamed to
      tsangertypePackages.tsangersirouti.
    '';

    siyaoxingkai = throw ''
      tsangertypeFonts.siyaoxingkai has been renamed to
      tsangertypePackages.tsangersyxk.
    '';

    siyecaodexingfu = throw ''
      tsangertypeFonts.siyecaodexingfu has been renamed to
      tsangertypePackages.tsangersycxft.
    '';

    songguo = throw ''
      tsangertypeFonts.songguo has been renamed to
      tsangertypePackages.tsangersgt.
    '';

    songkai = throw ''
      tsangertypeFonts.songkai has been renamed to
      tsangertypePackages.tsangersongkai.
    '';

    suxin = throw ''
      tsangertypeFonts.suxin has been renamed to
      tsangertypePackages.tsangersxt.
    '';

    tianmimi = throw ''
      tsangertypeFonts.tianmimi has been renamed to
      tsangertypePackages.tsangertmmt.
    '';

    tianmu-w01 = throw ''
      tsangertypeFonts.tianmu-w01 has been renamed to
      tsangertypePackages.tsangertmtgl.
    '';

    tianmu-w02 = throw ''
      tsangertypeFonts.tianmu-w02 has been renamed to
      tsangertypePackages.tsangertmtgl.
    '';

    tianmu-w03 = throw ''
      tsangertypeFonts.tianmu-w03 has been renamed to
      tsangertypePackages.tsangertmtgl.
    '';

    tianmu-w04 = throw ''
      tsangertypeFonts.tianmu-w04 has been renamed to
      tsangertypePackages.tsangertmtgl.
    '';

    tianmu-w05 = throw ''
      tsangertypeFonts.tianmu-w05 has been renamed to
      tsangertypePackages.tsangertmtgl.
    '';

    tianqunxingkai = throw ''
      tsangertypeFonts.tianqunxingkai has been renamed to
      tsangertypePackages.tsangertqxk.
    '';

    tiansuolele = throw ''
      tsangertypeFonts.tiansuolele has been renamed to
      tsangertypePackages.tsangertsllt.
    '';

    tingfeng = throw ''
      tsangertypeFonts.tingfeng has been renamed to
      tsangertypePackages.tsangertft.
    '';

    tongzhuo = throw ''
      tsangertypeFonts.tongzhuo has been renamed to
      tsangertypePackages.tsangertzt.
    '';

    tuya-w01 = throw ''
      tsangertypeFonts.tuya-w01 has been renamed to
      tsangertypePackages.tsangerty.
    '';

    tuya-w02 = throw ''
      tsangertypeFonts.tuya-w02 has been renamed to
      tsangertypePackages.tsangerty.
    '';

    tuya-w03 = throw ''
      tsangertypeFonts.tuya-w03 has been renamed to
      tsangertypePackages.tsangerty.
    '';

    wandongxingshu = throw ''
      tsangertypeFonts.wandongxingshu has been renamed to
      tsangertypePackages.tsangerwdxsjf.
    '';

    weilairiji = throw ''
      tsangertypeFonts.weilairiji has been renamed to
      tsangertypePackages.tsangerwlrjt.
    '';

    wugexingbuqingchun = throw ''
      tsangertypeFonts.wugexingbuqingchun has been renamed to
      tsangertypePackages.tsangerwgxbqct.
    '';

    wuliangshoufu = throw ''
      tsangertypeFonts.wuliangshoufu has been renamed to
      tsangertypePackages.tsangerwlsft.
    '';

    xiangzuozouxiangyouzou = throw ''
      tsangertypeFonts.xiangzuozouxiangyouzou has been renamed to
      tsangertypePackages.tsangerxzzxyzt.
    '';

    xiaobaikaishu = throw ''
      tsangertypeFonts.xiaobaikaishu has been renamed to
      tsangertypePackages.tsangerxbks.
    '';

    xiaobaiwan = throw ''
      tsangertypeFonts.xiaobaiwan has been renamed to
      tsangertypePackages.tsangergzt.
    '';

    xiaobaixingshu = throw ''
      tsangertypeFonts.xiaobaixingshu has been renamed to
      tsangertypePackages.tsangerxbxs.
    '';

    xiaodianer = throw ''
      tsangertypeFonts.xiaodianer has been renamed to
      tsangertypePackages.tsangerxdet.
    '';

    xiaofang = throw ''
      tsangertypeFonts.xiaofang has been renamed to
      tsangertypePackages.tsangerxft.
    '';

    xiaokeai-w01 = throw ''
      tsangertypeFonts.xiaokeai-w01 has been renamed to
      tsangertypePackages.tsangerxka.
    '';

    xiaokeai-w02 = throw ''
      tsangertypeFonts.xiaokeai-w02 has been renamed to
      tsangertypePackages.tsangerxka.
    '';

    xiaokeai-w03 = throw ''
      tsangertypeFonts.xiaokeai-w03 has been renamed to
      tsangertypePackages.tsangerxka.
    '';

    xiaokeai-w04 = throw ''
      tsangertypeFonts.xiaokeai-w04 has been renamed to
      tsangertypePackages.tsangerxka.
    '';

    xiaokeai-w05 = throw ''
      tsangertypeFonts.xiaokeai-w05 has been renamed to
      tsangertypePackages.tsangerxka.
    '';

    xiaokeai-w06 = throw ''
      tsangertypeFonts.xiaokeai-w06 has been renamed to
      tsangertypePackages.tsangerxka.
    '';

    xiaomanman-w01 = throw ''
      tsangertypeFonts.xiaomanman-w01 has been renamed to
      tsangertypePackages.tsangerxmmt.
    '';

    xiaomanman-w02 = throw ''
      tsangertypeFonts.xiaomanman-w02 has been renamed to
      tsangertypePackages.tsangerxmmt.
    '';

    xiaomanman-w03 = throw ''
      tsangertypeFonts.xiaomanman-w03 has been renamed to
      tsangertypePackages.tsangerxmmt.
    '';

    xiaomanman-w04 = throw ''
      tsangertypeFonts.xiaomanman-w04 has been renamed to
      tsangertypePackages.tsangerxmmt.
    '';

    xiaomanman-w05 = throw ''
      tsangertypeFonts.xiaomanman-w05 has been renamed to
      tsangertypePackages.tsangerxmmt.
    '';

    xiaoshipin = throw ''
      tsangertypeFonts.xiaoshipin has been renamed to
      tsangertypePackages.tsangerxspt.
    '';

    xiaowanzi = throw ''
      tsangertypeFonts.xiaowanzi has been renamed to
      tsangertypePackages.tsangerxwz.
    '';

    xiaowoniudemeng = throw ''
      tsangertypeFonts.xiaowoniudemeng has been renamed to
      tsangertypePackages.tsangerxwndm.
    '';

    xiaoxiaohuochai = throw ''
      tsangertypeFonts.xiaoxiaohuochai has been renamed to
      tsangertypePackages.tsangerxxhct.
    '';

    xiaoxiaomangguo = throw ''
      tsangertypeFonts.xiaoxiaomangguo has been renamed to
      tsangertypePackages.tsangerxxmgt.
    '';

    xiaoyaoxingshu = throw ''
      tsangertypeFonts.xiaoyaoxingshu has been renamed to
      tsangertypePackages.tsangerxyxs.
    '';

    xiaoyashouji = throw ''
      tsangertypeFonts.xiaoyashouji has been renamed to
      tsangertypePackages.tsangerxysj.
    '';

    xiaoyutongxue = throw ''
      tsangertypeFonts.xiaoyutongxue has been renamed to
      tsangertypePackages.tsangerxytxt.
    '';

    xiayizhanxingfu = throw ''
      tsangertypeFonts.xiayizhanxingfu has been renamed to
      tsangertypePackages.tsangerxyzxft.
    '';

    xingchenkaishu = throw ''
      tsangertypeFonts.xingchenkaishu has been renamed to
      tsangertypePackages.tsangerxcks.
    '';

    xingfuyuezhang = throw ''
      tsangertypeFonts.xingfuyuezhang has been renamed to
      tsangertypePackages.tsangerxflzt.
    '';

    xinghansong = throw ''
      tsangertypeFonts.xinghansong has been renamed to
      tsangertypePackages.tsangerxhsong.
    '';

    xinxing = throw ''
      tsangertypeFonts.xinxing has been renamed to
      tsangertypePackages.tsangerxxt.
    '';

    xinyan = throw ''
      tsangertypeFonts.xinyan has been renamed to
      tsangertypePackages.tsangerxinyanti.
    '';

    xinyue01 = throw ''
      tsangertypeFonts.xinyue01 has been renamed to
      tsangertypePackages.tsangerxinyueti.
    '';

    xinyue02 = throw ''
      tsangertypeFonts.xinyue02 has been renamed to
      tsangertypePackages.tsangerxyt.
    '';

    xiuxianxingshu = throw ''
      tsangertypeFonts.xiuxianxingshu has been renamed to
      tsangertypePackages.tsangerxxxs.
    '';

    xiuzhen = throw ''
      tsangertypeFonts.xiuzhen has been renamed to
      tsangertypePackages.tsangerxiuzhenti.
    '';

    xiyuan = throw ''
      tsangertypeFonts.xiyuan has been renamed to
      tsangertypePackages.tsangerxiyuanti.
    '';

    xuansan-01-w01 = throw ''
      tsangertypeFonts.xuansan-01-w01 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-01-w02 = throw ''
      tsangertypeFonts.xuansan-01-w02 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-01-w03 = throw ''
      tsangertypeFonts.xuansan-01-w03 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-01-w04 = throw ''
      tsangertypeFonts.xuansan-01-w04 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-01-w05 = throw ''
      tsangertypeFonts.xuansan-01-w05 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-02-w01 = throw ''
      tsangertypeFonts.xuansan-02-w01 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-02-w02 = throw ''
      tsangertypeFonts.xuansan-02-w02 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-02-w03 = throw ''
      tsangertypeFonts.xuansan-02-w03 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-02-w04 = throw ''
      tsangertypeFonts.xuansan-02-w04 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-02-w05 = throw ''
      tsangertypeFonts.xuansan-02-w05 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-03-w01 = throw ''
      tsangertypeFonts.xuansan-03-w01 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-03-w02 = throw ''
      tsangertypeFonts.xuansan-03-w02 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-03-w03 = throw ''
      tsangertypeFonts.xuansan-03-w03 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-03-w04 = throw ''
      tsangertypeFonts.xuansan-03-w04 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-03-w05 = throw ''
      tsangertypeFonts.xuansan-03-w05 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-04-w01 = throw ''
      tsangertypeFonts.xuansan-04-w01 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-04-w02 = throw ''
      tsangertypeFonts.xuansan-04-w02 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-04-w03 = throw ''
      tsangertypeFonts.xuansan-04-w03 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-04-w04 = throw ''
      tsangertypeFonts.xuansan-04-w04 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-04-w05 = throw ''
      tsangertypeFonts.xuansan-04-w05 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-m-w01 = throw ''
      tsangertypeFonts.xuansan-m-w01 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-m-w02 = throw ''
      tsangertypeFonts.xuansan-m-w02 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-m-w03 = throw ''
      tsangertypeFonts.xuansan-m-w03 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-m-w04 = throw ''
      tsangertypeFonts.xuansan-m-w04 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xuansan-m-w05 = throw ''
      tsangertypeFonts.xuansan-m-w05 has been renamed to
      tsangertypePackages.tsangerxuansan.
    '';

    xunmengshilitaohua = throw ''
      tsangertypeFonts.xunmengshilitaohua has been renamed to
      tsangertypePackages.tsangerxmsltht.
    '';

    xunzhaomoxianshouxie = throw ''
      tsangertypeFonts.xunzhaomoxianshouxie has been renamed to
      tsangertypePackages.tsangerxzmxsxt.
    '';

    yangguangmingmei = throw ''
      tsangertypeFonts.yangguangmingmei has been renamed to
      tsangertypePackages.tsangerygmmt.
    '';

    yangming = throw ''
      tsangertypeFonts.yangming has been renamed to
      tsangertypePackages.tsangeryangmingti.
    '';

    yaoguangxingshu = throw ''
      tsangertypeFonts.yaoguangxingshu has been renamed to
      tsangertypePackages.tsangerygxs.
    '';

    yasong = throw ''
      tsangertypeFonts.yasong has been renamed to
      tsangertypePackages.tsangeryasong.
    '';

    yayue = throw ''
      tsangertypeFonts.yayue has been renamed to
      tsangertypePackages.tsangeryayueti.
    '';

    yezhiling = throw ''
      tsangertypeFonts.yezhiling has been renamed to
      tsangertypePackages.tsangeryzlt.
    '';

    yihei-w01 = throw ''
      tsangertypeFonts.yihei-w01 has been renamed to
      tsangertypePackages.tsangeryihei.
    '';

    yihei-w02 = throw ''
      tsangertypeFonts.yihei-w02 has been renamed to
      tsangertypePackages.tsangeryihei.
    '';

    yihei-w03 = throw ''
      tsangertypeFonts.yihei-w03 has been renamed to
      tsangertypePackages.tsangeryihei.
    '';

    yihei-w04 = throw ''
      tsangertypeFonts.yihei-w04 has been renamed to
      tsangertypePackages.tsangeryihei.
    '';

    yihei-w05 = throw ''
      tsangertypeFonts.yihei-w05 has been renamed to
      tsangertypePackages.tsangeryihei.
    '';

    yinghe = throw ''
      tsangertypeFonts.yinghe has been renamed to
      tsangertypePackages.tsangeryinghe.
    '';

    yiranyizha = throw ''
      tsangertypeFonts.yiranyizha has been renamed to
      tsangertypePackages.tsangeryryzt.
    '';

    yishibuding = throw ''
      tsangertypeFonts.yishibuding has been renamed to
      tsangertypePackages.tsangerysbdt.
    '';

    yisong = throw ''
      tsangertypeFonts.yisong has been renamed to
      tsangertypePackages.tsangeryisong.
    '';

    yiyechunfeng = throw ''
      tsangertypeFonts.yiyechunfeng has been renamed to
      tsangertypePackages.tsangeryycft.
    '';

    youran = throw ''
      tsangertypeFonts.youran has been renamed to
      tsangertypePackages.tsangeryouran.
    '';

    yuanbao = throw ''
      tsangertypeFonts.yuanbao has been renamed to
      tsangertypePackages.tsangerybt.
    '';

    yuanbao-w01 = throw ''
      tsangertypeFonts.yuanbao-w01 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yuanbao-w02 = throw ''
      tsangertypeFonts.yuanbao-w02 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yuanbao-w03 = throw ''
      tsangertypeFonts.yuanbao-w03 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yuanbao-w04 = throw ''
      tsangertypeFonts.yuanbao-w04 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yuanbao-w05 = throw ''
      tsangertypeFonts.yuanbao-w05 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yucheng-w01 = throw ''
      tsangertypeFonts.yucheng-w01 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yucheng-w02 = throw ''
      tsangertypeFonts.yucheng-w02 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yucheng-w03 = throw ''
      tsangertypeFonts.yucheng-w03 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yucheng-w04 = throw ''
      tsangertypeFonts.yucheng-w04 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yucheng-w05 = throw ''
      tsangertypeFonts.yucheng-w05 has been renamed to
      tsangertypePackages.tsangeryctgl.
    '';

    yudong = throw ''
      tsangertypeFonts.yudong has been renamed to
      tsangertypePackages.tsangeryuedong.
    '';

    yuedong = throw ''
      tsangertypeFonts.yuedong has been renamed to
      tsangertypePackages.tsangeryuedong.
    '';

    yueman = throw ''
      tsangertypeFonts.yueman has been renamed to
      tsangertypePackages.tsangerymt.
    '';

    yukai = throw ''
      tsangertypeFonts.yukai has been renamed to
      tsangertypePackages.tsangeryukai.
    '';

    yule = throw ''
      tsangertypeFonts.yule has been renamed to
      tsangertypePackages.tsangerylt.
    '';

    yumo-w01 = throw ''
      tsangertypeFonts.yumo-w01 has been renamed to
      tsangertypePackages.tsangeryumo.
    '';

    yumo-w02 = throw ''
      tsangertypeFonts.yumo-w02 has been renamed to
      tsangertypePackages.tsangeryumo.
    '';

    yumo-w03 = throw ''
      tsangertypeFonts.yumo-w03 has been renamed to
      tsangertypePackages.tsangeryumo.
    '';

    yumo-w04 = throw ''
      tsangertypeFonts.yumo-w04 has been renamed to
      tsangertypePackages.tsangeryumo.
    '';

    yumo-w05 = throw ''
      tsangertypeFonts.yumo-w05 has been renamed to
      tsangertypePackages.tsangeryumo.
    '';

    yunhaisongtao = throw ''
      tsangertypeFonts.yunhaisongtao has been renamed to
      tsangertypePackages.tsangeryhstt.
    '';

    yunhei-w01 = throw ''
      tsangertypeFonts.yunhei-w01 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunhei-w02 = throw ''
      tsangertypeFonts.yunhei-w02 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunhei-w03 = throw ''
      tsangertypeFonts.yunhei-w03 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunhei-w04 = throw ''
      tsangertypeFonts.yunhei-w04 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunhei-w05 = throw ''
      tsangertypeFonts.yunhei-w05 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunhei-w06 = throw ''
      tsangertypeFonts.yunhei-w06 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunhei-w07 = throw ''
      tsangertypeFonts.yunhei-w07 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunhei-w08 = throw ''
      tsangertypeFonts.yunhei-w08 has been renamed to
      tsangertypePackages.tsangeryunhei.
    '';

    yunxuan = throw ''
      tsangertypeFonts.yunxuan has been renamed to
      tsangertypePackages.tsangeryxt.
    '';

    yuxiaoxiao = throw ''
      tsangertypeFonts.yuxiaoxiao has been renamed to
      tsangertypePackages.tsangeryxxt.
    '';

    yuyang-w01 = throw ''
      tsangertypeFonts.yuyang-w01 has been renamed to
      tsangertypePackages.tsangeryuyangt.
    '';

    yuyang-w02 = throw ''
      tsangertypeFonts.yuyang-w02 has been renamed to
      tsangertypePackages.tsangeryuyangt.
    '';

    yuyang-w03 = throw ''
      tsangertypeFonts.yuyang-w03 has been renamed to
      tsangertypePackages.tsangeryuyangt.
    '';

    yuyang-w04 = throw ''
      tsangertypeFonts.yuyang-w04 has been renamed to
      tsangertypePackages.tsangeryuyangt.
    '';

    yuyang-w05 = throw ''
      tsangertypeFonts.yuyang-w05 has been renamed to
      tsangertypePackages.tsangeryuyangt.
    '';

    zaijiannaxienian = throw ''
      tsangertypeFonts.zaijiannaxienian has been renamed to
      tsangertypePackages.tsangerzjnxnt.
    '';

    zengguofan = throw ''
      tsangertypeFonts.zengguofan has been renamed to
      tsangertypePackages.tsangerzgft.
    '';

    zhangyuxiaowanzi = throw ''
      tsangertypeFonts.zhangyuxiaowanzi has been renamed to
      tsangertypePackages.tsangerzyxwzt.
    '';

    zhenzhu = throw ''
      tsangertypeFonts.zhenzhu has been renamed to
      tsangertypePackages.tsangerzhenzhuti.
    '';

    zhiqu-w01 = throw ''
      tsangertypeFonts.zhiqu-w01 has been renamed to
      tsangertypePackages.tsangerzqtgl.
    '';

    zhiqu-w02 = throw ''
      tsangertypeFonts.zhiqu-w02 has been renamed to
      tsangertypePackages.tsangerzqtgl.
    '';

    zhiqu-w03 = throw ''
      tsangertypeFonts.zhiqu-w03 has been renamed to
      tsangertypePackages.tsangerzqtgl.
    '';

    zhiqu-w04 = throw ''
      tsangertypeFonts.zhiqu-w04 has been renamed to
      tsangertypePackages.tsangerzqtgl.
    '';

    zhiqu-w05 = throw ''
      tsangertypeFonts.zhiqu-w05 has been renamed to
      tsangertypePackages.tsangerzqtgl.
    '';

    zhixiangkanzheni = throw ''
      tsangertypeFonts.zhixiangkanzheni has been renamed to
      tsangertypePackages.tsangerzxkzn.
    '';

    zhixin = throw ''
      tsangertypeFonts.zhixin has been renamed to
      tsangertypePackages.tsangerzhixinti.
    '';

    zhiyuxiwenqing = throw ''
      tsangertypeFonts.zhiyuxiwenqing has been renamed to
      tsangertypePackages.tsangerzyxwq.
    '';

    zhoukezhengdabangshu = throw ''
      tsangertypeFonts.zhoukezhengdabangshu has been renamed to
      tsangertypePackages.tsangerzhoukezhengdabangshu.
    '';

    zhouxinyoulong = throw ''
      tsangertypeFonts.zhouxinyoulong has been renamed to
      tsangertypePackages.tsangerzxylt.
    '';

    zhuangyuankai = throw ''
      tsangertypeFonts.zhuangyuankai has been renamed to
      tsangertypePackages.tsangerzhuangyuankai.
    '';

    zhuyan = throw ''
      tsangertypeFonts.zhuyan has been renamed to
      tsangertypePackages.tsangerzhuyanti.
    '';

    zongheng = throw ''
      tsangertypeFonts.zongheng has been renamed to
      tsangertypePackages.tsangerzongheng.
    '';
  };

  windows-fonts = microsoftPackages.windows-fonts;
}
