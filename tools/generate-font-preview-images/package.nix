{
  alibabaPackages,
  alimamaPackages,
  buttaiwanPackages,
  coreutils,
  dingtalkPackages,
  findutils,
  fontconfig,
  foundertypePackages,
  git,
  gnused,
  huaweiPackages,
  imagemagick,
  justfontPackages,
  lib,
  microsoftPackages,
  pango,
  taobaoPackages,
  tianhengPackages,
  trionestypePackages,
  tsangertypePackages,
  writeShellScriptBin,
  writeText,
  xiaomiPackages,
  ...
}:
let
  inherit (lib)
    attrByPath
    concatLists
    concatStringsSep
    elem
    filterAttrs
    isDerivation
    licenses
    maintainers
    makeBinPath
    map
    mapAttrsToList
    ;

  fontPreviewScopes = {
    alibaba = alibabaPackages;
    alimama = alimamaPackages;
    buttaiwan = buttaiwanPackages;
    dingtalk = dingtalkPackages;
    foundertype = foundertypePackages;
    huawei = huaweiPackages;
    justfont = justfontPackages;
    microsoft = microsoftPackages;
    taobao = taobaoPackages;
    tianheng = tianhengPackages;
    trionestype = trionestypePackages;
    tsangertype = tsangertypePackages;
    xiaomi = xiaomiPackages;
  };

  fontPreviewPackageSampleKeys = {
    alibaba = {
      alibaba-puhuiti = "simplified-chinese";
      alibaba-puhuiti-2 = "simplified-chinese";
      alibaba-puhuiti-3 = "simplified-chinese";
      alibaba-sans = "english";
      alibaba-sans-hk = "traditional-chinese";
      alibaba-sans-jp = "japanese";
      alibaba-sans-kr = "korean";
      alibaba-sans-sea = "southeast-asian";
      alibaba-sans-tc = "traditional-chinese";
      alibaba-sans-thai = "thai";
      alibaba-sans-viet = "vietnamese";
    };

    alimama = {
      alimama-agile = "english";
      alimama-daoliti = "simplified-chinese";
      alimama-dongfangdakai = "simplified-chinese";
      alimama-fangyuanti = "simplified-chinese";
      alimama-shuheiti = "simplified-chinese";
    };

    buttaiwan = {
      buttaiwan-genkimin2-jp = "japanese";
      buttaiwan-genkimin2-pjp = "japanese";
      buttaiwan-genkimin2-tc = "traditional-chinese";
      buttaiwan-genkimin2-tw = "traditional-chinese";
      buttaiwan-genyomin2-jp = "japanese";
      buttaiwan-genyomin2-pjp = "japanese";
      buttaiwan-genyomin2-tc = "traditional-chinese";
      buttaiwan-genyomin2-tw = "traditional-chinese";
      buttaiwan-gensenrounded2-jp = "japanese";
      buttaiwan-gensenrounded2-pjp = "japanese";
      buttaiwan-gensenrounded2-tc = "traditional-chinese";
      buttaiwan-gensenrounded2-tw = "traditional-chinese";
      buttaiwan-gensekigothic2-jp = "japanese";
      buttaiwan-gensekigothic2-pjp = "japanese";
      buttaiwan-gensekigothic2-tc = "traditional-chinese";
      buttaiwan-gensekigothic2-tw = "traditional-chinese";
      buttaiwan-genkigothic2-jp = "japanese";
      buttaiwan-genkigothic2-pjp = "japanese";
      buttaiwan-genkigothic2-tc = "traditional-chinese";
      buttaiwan-genkigothic2-tw = "traditional-chinese";
      buttaiwan-genyogothic2-jp = "japanese";
      buttaiwan-genyogothic2-pjp = "japanese";
      buttaiwan-genyogothic2-tc = "traditional-chinese";
      buttaiwan-genyogothic2-tw = "traditional-chinese";
      buttaiwan-genwanmin2-jp = "japanese";
      buttaiwan-genwanmin2-pjp = "japanese";
      buttaiwan-genwanmin2-tc = "traditional-chinese";
      buttaiwan-genwanmin2-tw = "traditional-chinese";
      buttaiwan-genryumin2-jp = "japanese";
      buttaiwan-genryumin2-pjp = "japanese";
      buttaiwan-genryumin2-tc = "traditional-chinese";
      buttaiwan-genryumin2-tw = "traditional-chinese";
      buttaiwan-iansui = "traditional-chinese";
    };

    dingtalk = {
      dingtalk-jinbuti = "simplified-chinese";
    };

    foundertype = {
      foundertype-fzcuyuan = "simplified-chinese";
      foundertype-fzfangsong = "simplified-chinese";
      foundertype-fzheiti = "simplified-chinese";
      foundertype-fzkaiti = "simplified-chinese";
      foundertype-fzlishu = "simplified-chinese";
      foundertype-fzshusong = "simplified-chinese";
      foundertype-fzxiaobiaosong = "simplified-chinese";
      foundertype-fzxiheiyi = "simplified-chinese";
      foundertype-fzxiyuan = "simplified-chinese";
      foundertype-fzzhunyuan = "simplified-chinese";
    };

    huawei = {
      harmonyos-sans = "english";
      harmonyos-sans-sc = "simplified-chinese";
      harmonyos-sans-sc-vf = "simplified-chinese";
      harmonyos-sans-tc = "traditional-chinese";
      harmonyos-sans-tc-vf = "traditional-chinese";
      harmonyos-sans-vf = "english";
      harmonyos-sans-naskh-arabic = "arabic";
      harmonyos-sans-naskh-arabic-vf = "arabic";
      harmonyos-sans-naskh-arabic-ui = "arabic";
      harmonyos-sans-naskh-arabic-ui-vf = "arabic";
    };

    justfont = {
      justfont-abbrfesfont = "traditional-chinese";
      justfont-allpuntype = "traditional-chinese";
      justfont-elffont = "bopomofo";
      justfont-huninn = "traditional-chinese";
      justfont-snailfont = "english";
      justfont-the-write-right-font = "traditional-chinese";
      justfont-type-jam = "traditional-chinese";
    };

    microsoft = {
      microsoft-arial = "english";
      microsoft-bahnschrift = "english";
      microsoft-calibri = "english";
      microsoft-cambria = "english";
      microsoft-cambria-math = "math";
      microsoft-candara = "english";
      microsoft-comic-sans-ms = "english";
      microsoft-consolas = "english";
      microsoft-constantia = "english";
      microsoft-corbel = "english";
      microsoft-courier-new = "english";
      microsoft-dengxian = "simplified-chinese";
      microsoft-ebrima = "english";
      microsoft-fangsong = "simplified-chinese";
      microsoft-franklin-gothic-medium = "english";
      microsoft-gabriola = "english";
      microsoft-gadugi = "english";
      microsoft-georgia = "english";
      microsoft-impact = "english";
      microsoft-ink-free = "english";
      microsoft-javanese-text = "javanese";
      microsoft-kaiti = "simplified-chinese";
      microsoft-leelawadee-ui = "thai";
      microsoft-lucida-console = "english";
      microsoft-lucida-sans-unicode = "english";
      microsoft-malgun-gothic = "korean";
      microsoft-marlett = "marlett";
      microsoft-microsoft-himalaya = "tibetan";
      microsoft-microsoft-jhenghei = "traditional-chinese";
      microsoft-microsoft-new-tai-lue = "tai-lue";
      microsoft-microsoft-phagspa = "phagspa";
      microsoft-microsoft-sans-serif = "english";
      microsoft-microsoft-tai-le = "tai-le";
      microsoft-microsoft-yahei = "simplified-chinese";
      microsoft-microsoft-yi-baiti = "yi";
      microsoft-mingliu = "traditional-chinese";
      microsoft-mongolian-baiti = "mongolian";
      microsoft-ms-gothic = "japanese";
      microsoft-mv-boli = "english";
      microsoft-myanmar-text = "myanmar";
      microsoft-nirmala = "devanagari";
      microsoft-noto-sans-sc = "simplified-chinese";
      microsoft-noto-serif-sc = "simplified-chinese";
      microsoft-palatino-linotype = "english";
      microsoft-sans-serif-collection = "english";
      microsoft-segoe-icons = "segoe-icons";
      microsoft-segoe-print = "english";
      microsoft-segoe-script = "english";
      microsoft-segoe-ui = "english";
      microsoft-segoe-ui-symbols = "segoe-ui-symbols";
      microsoft-segoe-ui-variable = "english";
      microsoft-simhei = "simplified-chinese";
      microsoft-simsun = "simplified-chinese";
      microsoft-sitka = "english";
      microsoft-sylfaen = "english";
      microsoft-symbol = "symbol-legacy";
      microsoft-tahoma = "english";
      microsoft-times-new-roman = "english";
      microsoft-trebuchet-ms = "english";
      microsoft-verdana = "english";
      microsoft-webdings = "webdings";
      microsoft-wingdings = "wingdings";
      microsoft-yu-gothic = "japanese";
    };

    taobao = {
      taobao-maicaiti = "simplified-chinese";
    };

    tianheng = {
      tianheng-hak = "traditional-chinese";
      tianheng-joeng = "traditional-chinese";
      tianheng-khaai-p = "traditional-chinese";
      tianheng-khaai-t = "simplified-chinese";
      tianheng-ming = "japanese";
      tianheng-sung-p = "traditional-chinese";
      tianheng-sung-t = "simplified-chinese";
      tianheng-sy = "simplified-chinese";
      tianheng-tshyn = "simplified-chinese";
    };

    trionestype = {
      trionestype-zhuque-fangsong = "simplified-chinese";
    };

    tsangertype = {
      tsangertype-tsangeradkkt = "simplified-chinese";
      tsangertype-tsangeramxingkai = "simplified-chinese";
      tsangertype-tsangeramxk = "simplified-chinese";
      tsangertype-tsangeramxs = "simplified-chinese";
      tsangertype-tsangeranmmdt = "simplified-chinese";
      tsangertype-tsangeraqlxs = "simplified-chinese";
      tsangertype-tsangerbanghei = "simplified-chinese";
      tsangertype-tsangerbblt = "simplified-chinese";
      tsangertype-tsangerblgl = "simplified-chinese";
      tsangertype-tsangerbmzct = "simplified-chinese";
      tsangertype-tsangerbtsz = "simplified-chinese";
      tsangertype-tsangerchuangyi = "simplified-chinese";
      tsangertype-tsangerchunfeng = "simplified-chinese";
      tsangertype-tsangercllsj = "simplified-chinese";
      tsangertype-tsangercsskdfxt = "simplified-chinese";
      tsangertype-tsangercyt = "simplified-chinese";
      tsangertype-tsangerczbjxks = "simplified-chinese";
      tsangertype-tsangerczbksjf = "simplified-chinese";
      tsangertype-tsangerczblyks = "simplified-chinese";
      tsangertype-tsangerczbxkjf = "simplified-chinese";
      tsangertype-tsangerdajiti = "simplified-chinese";
      tsangertype-tsangerddt = "simplified-chinese";
      tsangertype-tsangerdfzst = "simplified-chinese";
      tsangertype-tsangerdmmt = "simplified-chinese";
      tsangertype-tsangerdmxmtt = "simplified-chinese";
      tsangertype-tsangerdnsxt = "simplified-chinese";
      tsangertype-tsangerdscjt = "simplified-chinese";
      tsangertype-tsangerdubaiti = "simplified-chinese";
      tsangertype-tsangerdwt = "simplified-chinese";
      tsangertype-tsangerfanghei = "simplified-chinese";
      tsangertype-tsangerfec = "simplified-chinese";
      tsangertype-tsangerfeibai = "simplified-chinese";
      tsangertype-tsangerfenghei = "simplified-chinese";
      tsangertype-tsangerfft = "simplified-chinese";
      tsangertype-tsangerfgxsxst = "simplified-chinese";
      tsangertype-tsangerftt = "simplified-chinese";
      tsangertype-tsangerfwjt = "simplified-chinese";
      tsangertype-tsangerfyt = "simplified-chinese";
      tsangertype-tsangergdxxt = "simplified-chinese";
      tsangertype-tsangergfks = "simplified-chinese";
      tsangertype-tsangergfxs = "simplified-chinese";
      tsangertype-tsangergqimingti = "simplified-chinese";
      tsangertype-tsangergtt = "simplified-chinese";
      tsangertype-tsangerguli = "simplified-chinese";
      tsangertype-tsangerguyun = "simplified-chinese";
      tsangertype-tsangergxtyt = "simplified-chinese";
      tsangertype-tsangergzt = "simplified-chinese";
      tsangertype-tsangerhby = "simplified-chinese";
      tsangertype-tsangerhft = "simplified-chinese";
      tsangertype-tsangerhltxst = "simplified-chinese";
      tsangertype-tsangerhst = "simplified-chinese";
      tsangertype-tsangerhuaxinti = "simplified-chinese";
      tsangertype-tsangerjdks = "simplified-chinese";
      tsangertype-tsangerjdxs = "simplified-chinese";
      tsangertype-tsangerjinkai = "simplified-chinese";
      tsangertype-tsangerjkt = "simplified-chinese";
      tsangertype-tsangerjmt = "simplified-chinese";
      tsangertype-tsangerjsryt = "simplified-chinese";
      tsangertype-tsangerjtmqdt = "simplified-chinese";
      tsangertype-tsangerjxt = "simplified-chinese";
      tsangertype-tsangerjyt = "simplified-chinese";
      tsangertype-tsangerjzcf = "simplified-chinese";
      tsangertype-tsangerjzw = "simplified-chinese";
      tsangertype-tsangerkeketi = "simplified-chinese";
      tsangertype-tsangerklks = "simplified-chinese";
      tsangertype-tsangerkuhei = "simplified-chinese";
      tsangertype-tsangerlabjt = "simplified-chinese";
      tsangertype-tsangerlankai = "simplified-chinese";
      tsangertype-tsangerlifeiti = "simplified-chinese";
      tsangertype-tsangerlinggang = "simplified-chinese";
      tsangertype-tsangerlishiti = "simplified-chinese";
      tsangertype-tsangerliyuan = "simplified-chinese";
      tsangertype-tsangerlkkt = "simplified-chinese";
      tsangertype-tsangerllbjt = "simplified-chinese";
      tsangertype-tsangerlyt = "simplified-chinese";
      tsangertype-tsangerlzhft = "simplified-chinese";
      tsangertype-tsangerlzt = "simplified-chinese";
      tsangertype-tsangermanmiao = "simplified-chinese";
      tsangertype-tsangermbht = "simplified-chinese";
      tsangertype-tsangermbkjt = "simplified-chinese";
      tsangertype-tsangermddt = "simplified-chinese";
      tsangertype-tsangermdmwt = "simplified-chinese";
      tsangertype-tsangermeixin = "simplified-chinese";
      tsangertype-tsangermengdie = "simplified-chinese";
      tsangertype-tsangerminghei = "simplified-chinese";
      tsangertype-tsangermingkai = "simplified-chinese";
      tsangertype-tsangermingyueti = "simplified-chinese";
      tsangertype-tsangermmdxdzt = "simplified-chinese";
      tsangertype-tsangermmjt = "simplified-chinese";
      tsangertype-tsangermochati = "simplified-chinese";
      tsangertype-tsangermtls = "simplified-chinese";
      tsangertype-tsangermxlbt = "simplified-chinese";
      tsangertype-tsangermxt = "simplified-chinese";
      tsangertype-tsangermzgt = "simplified-chinese";
      tsangertype-tsangernhsgt = "simplified-chinese";
      tsangertype-tsangernnszt = "simplified-chinese";
      tsangertype-tsangernswdqsj = "simplified-chinese";
      tsangertype-tsangernswdwy = "simplified-chinese";
      tsangertype-tsangernwt = "simplified-chinese";
      tsangertype-tsangernxt = "simplified-chinese";
      tsangertype-tsangerpbt = "simplified-chinese";
      tsangertype-tsangerpmt = "simplified-chinese";
      tsangertype-tsangerqcynwmt = "simplified-chinese";
      tsangertype-tsangerqczka = "simplified-chinese";
      tsangertype-tsangerqeddt = "simplified-chinese";
      tsangertype-tsangerqft = "simplified-chinese";
      tsangertype-tsangerqfxyt = "simplified-chinese";
      tsangertype-tsangerqht = "simplified-chinese";
      tsangertype-tsangerqhtgl = "simplified-chinese";
      tsangertype-tsangerqiaoleti = "simplified-chinese";
      tsangertype-tsangerqingjiti = "simplified-chinese";
      tsangertype-tsangerqingsongti = "simplified-chinese";
      tsangertype-tsangerqingya = "simplified-chinese";
      tsangertype-tsangerqingyou = "simplified-chinese";
      tsangertype-tsangerqmt = "simplified-chinese";
      tsangertype-tsangerqnt = "simplified-chinese";
      tsangertype-tsangerqqmzt = "simplified-chinese";
      tsangertype-tsangerqqt = "simplified-chinese";
      tsangertype-tsangerqqxj = "simplified-chinese";
      tsangertype-tsangerquhei = "simplified-chinese";
      tsangertype-tsangerqxt = "simplified-chinese";
      tsangertype-tsangerqyt = "simplified-chinese";
      tsangertype-tsangerrouhei = "simplified-chinese";
      tsangertype-tsangerruihei = "simplified-chinese";
      tsangertype-tsangerrunhei = "simplified-chinese";
      tsangertype-tsangersangqi = "simplified-chinese";
      tsangertype-tsangersgt = "simplified-chinese";
      tsangertype-tsangershuhei = "simplified-chinese";
      tsangertype-tsangershuyuant = "simplified-chinese";
      tsangertype-tsangersirouti = "simplified-chinese";
      tsangertype-tsangersnxscyt = "simplified-chinese";
      tsangertype-tsangersongkai = "simplified-chinese";
      tsangertype-tsangersqdddt = "simplified-chinese";
      tsangertype-tsangerssrs = "simplified-chinese";
      tsangertype-tsangersxt = "simplified-chinese";
      tsangertype-tsangersycxft = "simplified-chinese";
      tsangertype-tsangersyxk = "simplified-chinese";
      tsangertype-tsangertft = "simplified-chinese";
      tsangertype-tsangertmmt = "simplified-chinese";
      tsangertype-tsangertmtgl = "simplified-chinese";
      tsangertype-tsangertqxk = "simplified-chinese";
      tsangertype-tsangertsllt = "simplified-chinese";
      tsangertype-tsangerty = "simplified-chinese";
      tsangertype-tsangertzt = "simplified-chinese";
      tsangertype-tsangerwdxsjf = "simplified-chinese";
      tsangertype-tsangerwgxbqct = "simplified-chinese";
      tsangertype-tsangerwlrjt = "simplified-chinese";
      tsangertype-tsangerwlsft = "simplified-chinese";
      tsangertype-tsangerxbks = "simplified-chinese";
      tsangertype-tsangerxbxs = "simplified-chinese";
      tsangertype-tsangerxcks = "simplified-chinese";
      tsangertype-tsangerxdet = "simplified-chinese";
      tsangertype-tsangerxflzt = "simplified-chinese";
      tsangertype-tsangerxft = "simplified-chinese";
      tsangertype-tsangerxhsong = "simplified-chinese";
      tsangertype-tsangerxka = "simplified-chinese";
      tsangertype-tsangerxinyanti = "simplified-chinese";
      tsangertype-tsangerxinyueti = "simplified-chinese";
      tsangertype-tsangerxiuzhenti = "simplified-chinese";
      tsangertype-tsangerxiyuanti = "simplified-chinese";
      tsangertype-tsangerxmmt = "simplified-chinese";
      tsangertype-tsangerxmsltht = "simplified-chinese";
      tsangertype-tsangerxspt = "simplified-chinese";
      tsangertype-tsangerxuansan = "simplified-chinese";
      tsangertype-tsangerxwndm = "simplified-chinese";
      tsangertype-tsangerxwz = "simplified-chinese";
      tsangertype-tsangerxxhct = "simplified-chinese";
      tsangertype-tsangerxxmgt = "simplified-chinese";
      tsangertype-tsangerxxt = "simplified-chinese";
      tsangertype-tsangerxxxs = "simplified-chinese";
      tsangertype-tsangerxysj = "simplified-chinese";
      tsangertype-tsangerxyt = "simplified-chinese";
      tsangertype-tsangerxytxt = "simplified-chinese";
      tsangertype-tsangerxyxs = "simplified-chinese";
      tsangertype-tsangerxyzxft = "simplified-chinese";
      tsangertype-tsangerxzmxsxt = "simplified-chinese";
      tsangertype-tsangerxzzxyzt = "simplified-chinese";
      tsangertype-tsangeryangmingti = "simplified-chinese";
      tsangertype-tsangeryasong = "simplified-chinese";
      tsangertype-tsangeryayueti = "simplified-chinese";
      tsangertype-tsangerybt = "simplified-chinese";
      tsangertype-tsangeryctgl = "simplified-chinese";
      tsangertype-tsangerygmmt = "simplified-chinese";
      tsangertype-tsangerygxs = "simplified-chinese";
      tsangertype-tsangeryhstt = "simplified-chinese";
      tsangertype-tsangeryihei = "simplified-chinese";
      tsangertype-tsangeryinghe = "simplified-chinese";
      tsangertype-tsangeryisong = "simplified-chinese";
      tsangertype-tsangerylt = "simplified-chinese";
      tsangertype-tsangerymt = "simplified-chinese";
      tsangertype-tsangeryouran = "simplified-chinese";
      tsangertype-tsangeryryzt = "simplified-chinese";
      tsangertype-tsangerysbdt = "simplified-chinese";
      tsangertype-tsangeryuedong = "simplified-chinese";
      tsangertype-tsangeryukai = "simplified-chinese";
      tsangertype-tsangeryumo = "simplified-chinese";
      tsangertype-tsangeryunhei = "simplified-chinese";
      tsangertype-tsangeryuyangt = "simplified-chinese";
      tsangertype-tsangeryxt = "simplified-chinese";
      tsangertype-tsangeryxxt = "simplified-chinese";
      tsangertype-tsangeryycft = "simplified-chinese";
      tsangertype-tsangeryzlt = "simplified-chinese";
      tsangertype-tsangerzgft = "simplified-chinese";
      tsangertype-tsangerzhenzhuti = "simplified-chinese";
      tsangertype-tsangerzhixinti = "simplified-chinese";
      tsangertype-tsangerzhoukezhengdabangshu = "simplified-chinese";
      tsangertype-tsangerzhuangyuankai = "simplified-chinese";
      tsangertype-tsangerzhuyanti = "simplified-chinese";
      tsangertype-tsangerzjnxnt = "simplified-chinese";
      tsangertype-tsangerzongheng = "simplified-chinese";
      tsangertype-tsangerzqtgl = "simplified-chinese";
      tsangertype-tsangerzxkzn = "simplified-chinese";
      tsangertype-tsangerzxylt = "simplified-chinese";
      tsangertype-tsangerzyxwq = "simplified-chinese";
      tsangertype-tsangerzyxwzt = "simplified-chinese";
    };

    xiaomi = {
      misans-arabic = "arabic";
      misans-arabic-vf = "arabic";
      misans-arabic-ui = "arabic";
      misans-arabic-ui-vf = "arabic";
      misans-devanagari = "devanagari";
      misans-devanagari-vf = "devanagari";
      misans-gurmukhi = "gurmukhi";
      misans-gurmukhi-vf = "gurmukhi";
      misans-gujarati = "gujarati";
      misans-gujarati-vf = "gujarati";
      misans = "simplified-chinese";
      misans-khmer = "khmer";
      misans-khmer-vf = "khmer";
      misans-l3 = "rare-chinese";
      misans-lao = "lao";
      misans-lao-vf = "lao";
      misans-latin = "english";
      misans-latin-vf = "english";
      misans-myanmar = "myanmar";
      misans-myanmar-vf = "myanmar";
      misans-tc = "traditional-chinese";
      misans-tc-vf = "traditional-chinese";
      misans-thai = "thai";
      misans-thai-vf = "thai";
      misans-tibetan = "tibetan";
      misans-tibetan-vf = "tibetan";
      misans-vf = "simplified-chinese";
    };
  };

  fontPreviewExcludedPackagePnames = {
    microsoft = [
      "windows-fonts"
    ];
  };

  fontPreviewSkippedFontNames = { };

  fontPreviewRuntimePackages = [
    coreutils
    findutils
    fontconfig
    git
    gnused
    imagemagick
    pango
  ];

  fontPreviewMissingSampleKey = "__missing_sample_key__";

  fontPreviewSampleKey =
    scopeName: pname:
    attrByPath
      [
        scopeName
        pname
      ]
      fontPreviewMissingSampleKey
      fontPreviewPackageSampleKeys;

  fontPreviewSkippedFontRows = concatLists (
    mapAttrsToList (
      scopeName: scope:
      concatLists (
        mapAttrsToList (
          pname: fontNames:
          map (
            fontName:
            concatStringsSep "\t" [
              scopeName
              pname
              fontName
            ]
          ) fontNames
        ) scope
      )
    ) fontPreviewSkippedFontNames
  );

  fontPreviewPackageRows =
    scopeName: scope:
    mapAttrsToList
      (
        _: package:
        concatStringsSep "\t" [
          scopeName
          package.pname
          (fontPreviewSampleKey scopeName package.pname)
          (toString package)
        ]
      )
      (
        filterAttrs (
          _: package:
          (isDerivation package)
          && (
            !(elem package.pname (
              attrByPath
                [
                  scopeName
                ]
                [ ]
                fontPreviewExcludedPackagePnames
            ))
          )
        ) scope
      );

  fontPreviewManifest =
    writeText "font-preview-packages.tsv"
      (
        (concatStringsSep "\n" (
          concatLists (
            mapAttrsToList fontPreviewPackageRows fontPreviewScopes
          )
        ))
        + "\n"
      );

  fontPreviewSkippedFontManifest =
    writeText "font-preview-skipped-fonts.tsv"
      (
        (concatStringsSep "\n" fontPreviewSkippedFontRows)
        + "\n"
      );
in
(writeShellScriptBin "generate-font-preview-images" ''
  set -euo pipefail

  export PATH=${makeBinPath fontPreviewRuntimePackages}

  arabic_sample='أنا أستطيع أكل الزجاج ولا يؤلمني'
  bopomofo_sample='ㄨㄛˇ ㄋㄥˊ ㄊㄨㄣ ㄒㄧㄚˋ ㄅㄛ ˙ㄌㄧ ㄦˊ ㄅㄨˋ ㄕㄤ ㄕㄣ ㄊㄧˇ'
  english_sample='I can eat glass, it does not hurt me'
  devanagari_sample='मैं काँच खा सकता हूँ, मुझे इससे चोट नहीं लगती'
  gurmukhi_sample='ਮੈਂ ਕੱਚ ਖਾ ਸਕਦਾ ਹਾਂ, ਮੈਨੂੰ ਇਸ ਨਾਲ ਸੱਟ ਨਹੀਂ ਲੱਗਦੀ'
  gujarati_sample='હું કાચ ખાઈ શકું છું, તે મને ઈજા કરતું નથી'
  japanese_sample='私はガラスを食べられます。それは私を傷つけません。'
  javanese_sample='Aku bisa mangan kaca tanpa lara'
  khmer_sample='ខ្ញុំអាចញ៉ាំកញ្ចក់បាន វាមិនធ្វើឲ្យខ្ញុំឈឺទេ'
  korean_sample='나는 유리를 먹을 수 있어요. 그래도 아프지 않아요.'
  lao_sample='ຂ້ອຍກິນແກ້ວໄດ້ ມັນບໍ່ເຮັດໃຫ້ຂ້ອຍເຈັບ'
  marlett_sample='E +, "#$% *:'
  math_sample='e^{iπ} + 1 = 0'
  mongolian_sample='ᠪᠢ ᠰᠢᠯᠢ ᠢᠳᠡᠶᠦ ᠴᠢᠳᠠᠨᠠ ᠂ ᠨᠠᠳᠤᠷ ᠬᠣᠤᠷᠠᠳᠠᠢ ᠪᠢᠰᠢ'
  myanmar_sample='ကျွန်တော် ကျွန်မ မှန်စားနိုင်တယ်။ ၎င်းကြောင့် ထိခိုက်မှုမရှိပါ။'
  phagspa_sample='ꡢꡡ ꡋꡦꡃ ꡉꡟꡋ ꡜꡠꡝ ꡎꡡ ꡙꡞ ꡝꡖꡞ ꡎꡟ ꡚꡏ ꡚꡞꡋ ꡉꡞ'
  rare_chinese_sample='𫗦𤥗 𭴊𢦏𦝡'
  segoe_icons_sample=$'\uE726 \uE727 \uE814 \uE95E \uE930'
  segoe_ui_emoji_sample='😋 🪟 → 🙂 ✅'
  segoe_ui_historic_sample='𐌹 𐌺 𓀀 𓂀 𓏏'
  segoe_ui_symbol_sample='☕ ◊ → ☺ ⚕ ✓'
  simplified_sample='我能吞下玻璃而不伤身体'
  symbols_sample='p → ¬q, p ∴ ¬q'
  symbol_legacy_sample='abgde + pq = W'
  tai_le_sample='ᥐᥦᥝᥲ ᥐᥤᥢ ᥘᥭᥲ ᥕᥧᥱ, ᥟᥛᥱ ᥞᥥᥖᥱ ᥞᥬᥲ ᥖᥨᥝ ᥓᥥᥙᥲ'
  tai_lue_sample='ᦅᦵᦂᧁᧉ ᦂᦲᧃ ᦺᦡᧉ ᦢᧈ ᦵᦔᧃ ᦵᦈᧇ ᦎᦷᧅ'
  thai_sample='ฉันกินกระจกได้ แต่มันไม่ทำให้ฉันเจ็บ'
  tibetan_sample='ཤེལ་སྒོ་ཟ་ནས་ང་ན་གི་མ་རེད།'
  traditional_sample='我能吞下玻璃而不傷身體'
  vietnamese_sample='Tôi có thể ăn thủy tinh mà không hại gì.'
  webdings_sample='m 4 c 4 d 4 a'
  wingdings_sample='I E $ E B J C'
  yi_sample='ꉢꋤꇓꅝꇬꑌꇭꀧꀋꌸ'

  usage() {
    printf 'usage: %s [--override] [--package-name pname[,pname...]]\n' \
      "$(basename -- "$0")" >&2
  }

  project_root() {
    if root=$(git rev-parse --show-toplevel 2>/dev/null); then
      printf '%s\n' "$root"
      return
    fi

    printf '%s\n' \
      'cannot find project root; run inside this repository' >&2
    exit 1
  }

  font_family_name() {
    local font=$1
    local font_file
    local name

    name="$(
      fc-scan --format '%{family}\n' "$font" \
        | sed -n '1{
          s/,.*//
          s#/#-#g
          s/^[[:space:]]*//
          s/[[:space:]]*$//
          p
          q
        }'
    )"

    if [ -z "$name" ]; then
      font_file=$(basename -- "$font")
      name=''${font_file%.*}
    fi

    printf '%s\n' "$name"
  }

  font_style_name() {
    local font=$1

    fc-scan --format '%{style}\n' "$font" \
      | sed -n '1{
        s/,.*//
        s#/#-#g
        s/^[[:space:]]*//
        s/[[:space:]]*$//
        p
        q
      }'
  }

  is_blank_image() {
    local colors
    local image=$1

    colors=$(magick identify -format '%k' "$image")
    [ "$colors" -le 1 ]
  }

  render_with_magick() {
    local font=$1
    local output=$2
    local sample=$3

    magick \
      -quiet \
      -background white \
      -fill black \
      -font "$font" \
      -pointsize 64 \
      -gravity center \
      -size 1600x360 \
      "caption:$sample" \
      -trim \
      +repage \
      -bordercolor white \
      -border 16x16 \
      "$output"
  }

  render_with_pango() {
    local fontconfig_file=$1
    local font_name=$2
    local output=$3
    local pango_image
    local sample=$4

    pango_image=$(mktemp "$(dirname "$output")/.preview-pango.XXXXXX.png")

    FONTCONFIG_FILE=$fontconfig_file \
      pango-view \
        --no-display \
        --pixels \
        --background=white \
        --foreground=black \
        --font="$font_name 64" \
        --width=30000 \
        --align=center \
        --single-par \
        --output="$pango_image" \
        --text="$sample"

    magick \
      "$pango_image" \
      -trim \
      +repage \
      -resize '1200x360>' \
      -bordercolor white \
      -border 16x16 \
      "$output"

    rm -f "$pango_image"
  }

  choose_sample() {
    local sample_key=$1
    local font_name=''${2:-}

    case "$sample_key" in
      arabic)
        printf '%s\n' "$arabic_sample"
        ;;
      bopomofo)
        printf '%s\n' "$bopomofo_sample"
        ;;
      english)
        printf '%s\n' "$english_sample"
        ;;
      devanagari)
        printf '%s\n' "$devanagari_sample"
        ;;
      gurmukhi)
        printf '%s\n' "$gurmukhi_sample"
        ;;
      gujarati)
        printf '%s\n' "$gujarati_sample"
        ;;
      japanese)
        printf '%s\n' "$japanese_sample"
        ;;
      javanese)
        printf '%s\n' "$javanese_sample"
        ;;
      khmer)
        printf '%s\n' "$khmer_sample"
        ;;
      korean)
        printf '%s\n' "$korean_sample"
        ;;
      lao)
        printf '%s\n' "$lao_sample"
        ;;
      marlett)
        printf '%s\n' "$marlett_sample"
        ;;
      math)
        printf '%s\n' "$math_sample"
        ;;
      mongolian)
        printf '%s\n' "$mongolian_sample"
        ;;
      myanmar)
        printf '%s\n' "$myanmar_sample"
        ;;
      phagspa)
        printf '%s\n' "$phagspa_sample"
        ;;
      rare-chinese)
        printf '%s\n' "$rare_chinese_sample"
        ;;
      segoe-icons)
        printf '%s\n' "$segoe_icons_sample"
        ;;
      segoe-ui-symbols)
        case "$font_name" in
          'Segoe UI Emoji')
            printf '%s\n' "$segoe_ui_emoji_sample"
            ;;
          'Segoe UI Historic')
            printf '%s\n' "$segoe_ui_historic_sample"
            ;;
          *)
            printf '%s\n' "$segoe_ui_symbol_sample"
            ;;
        esac
        ;;
      simplified-chinese)
        printf '%s\n' "$simplified_sample"
        ;;
      symbols)
        printf '%s\n' "$symbols_sample"
        ;;
      symbol-legacy)
        printf '%s\n' "$symbol_legacy_sample"
        ;;
      tai-le)
        printf '%s\n' "$tai_le_sample"
        ;;
      tai-lue)
        printf '%s\n' "$tai_lue_sample"
        ;;
      southeast-asian)
        printf '%s\n%s\n' "$thai_sample" "$vietnamese_sample"
        ;;
      thai)
        printf '%s\n' "$thai_sample"
        ;;
      tibetan)
        printf '%s\n' "$tibetan_sample"
        ;;
      traditional-chinese)
        printf '%s\n' "$traditional_sample"
        ;;
      vietnamese)
        printf '%s\n' "$vietnamese_sample"
        ;;
      webdings)
        printf '%s\n' "$webdings_sample"
        ;;
      wingdings)
        printf '%s\n' "$wingdings_sample"
        ;;
      yi)
        printf '%s\n' "$yi_sample"
        ;;
      *)
        printf 'unknown font preview sample key: %s\n' "$sample_key" >&2
        exit 1
        ;;
    esac
  }

  declare -A skipped_font_names=()

  while IFS=$'\t' read -r skipped_scope skipped_pname skipped_font_name; do
    skipped_font_names["$skipped_scope"$'\t'"$skipped_pname"$'\t'"$skipped_font_name"]=1
  done < ${fontPreviewSkippedFontManifest}

  should_skip_font() {
    local font_name=$3
    local key
    local pname=$2
    local scope=$1

    key="$scope"$'\t'"$pname"$'\t'"$font_name"

    [ "''${skipped_font_names[$key]+set}" = set ]
  }

  override=false
  declare -A selected_package_names=()
  package_name_filter=false

  add_package_names() {
    local name
    local -a package_name_items
    local package_names=$1

    if [ -z "$package_names" ]; then
      printf 'empty --package-name value\n' >&2
      exit 2
    fi

    IFS=, read -r -a package_name_items <<< "$package_names"

    for name in "''${package_name_items[@]}"; do
      if [ -z "$name" ]; then
        printf 'empty package name in --package-name value: %s\n' \
          "$package_names" >&2
        exit 2
      fi

      selected_package_names["$name"]=0
    done

    package_name_filter=true
  }

  should_generate_package() {
    local pname=$1

    if [ "$package_name_filter" = false ]; then
      return 0
    fi

    if [ "''${selected_package_names[$pname]+set}" = set ]; then
      selected_package_names["$pname"]=1
      return 0
    fi

    return 1
  }

  validate_package_name_filter() {
    local manifest=$1
    local package
    local pname
    local sample_key
    local scope

    if [ "$package_name_filter" = false ]; then
      return
    fi

    while IFS=$'\t' read -r scope pname sample_key package; do
      if [ "''${selected_package_names[$pname]+set}" != set ]; then
        continue
      fi

      selected_package_names["$pname"]=1

      if [ "$sample_key" = "__missing_sample_key__" ]; then
        printf 'font preview sample key is not configured for %s.%s\n' \
          "$scope" "$pname" >&2
        exit 1
      fi
    done < "$manifest"

    for pname in "''${!selected_package_names[@]}"; do
      if [ "''${selected_package_names[$pname]}" = 0 ]; then
        printf 'unknown font preview package name: %s\n' "$pname" >&2
        exit 1
      fi
    done
  }

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --override)
        override=true
        shift
        ;;
      --package-name)
        if [ "$#" -lt 2 ]; then
          usage
          exit 2
        fi

        add_package_names "$2"
        shift 2
        ;;
      --package-name=*)
        add_package_names "''${1#--package-name=}"
        shift
        ;;
      *)
        usage
        exit 2
        ;;
    esac
  done

  validate_package_name_filter "${fontPreviewManifest}"

  output_dir=$(project_root)/font-preview-images
  mkdir -p "$output_dir"

  while IFS=$'\t' read -r scope pname sample_key package; do
    if ! should_generate_package "$pname"; then
      continue
    fi

    fonts_dir=$package/share/fonts
    scope_dir=$output_dir/$scope

    if [ "$sample_key" = "__missing_sample_key__" ]; then
      printf 'font preview sample key is not configured for %s.%s\n' \
        "$scope" "$pname" >&2
      exit 1
    fi

    if [ ! -d "$fonts_dir" ]; then
      continue
    fi

    mkdir -p "$scope_dir"

    fontconfig_file=$(mktemp "$scope_dir/.fontconfig.XXXXXX.conf")
    {
      printf '%s\n' '<?xml version="1.0"?>'
      printf '%s\n' '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">'
      printf '%s\n' '<fontconfig>'
      printf '  <dir>%s</dir>\n' "$fonts_dir"
      printf '%s\n' '</fontconfig>'
    } > "$fontconfig_file"

    declare -A family_counts=()
    declare -A image_counts=()
    font_paths=()
    font_names=()
    font_styles=()

    while IFS= read -r -d "" font; do
      font_name=$(font_family_name "$font")
      font_paths+=("$font")
      font_names+=("$font_name")
      font_styles+=("$(font_style_name "$font")")
      family_counts["$font_name"]=$(( ''${family_counts[$font_name]:-0} + 1 ))
    done < <(
      find "$fonts_dir" \
        -type f \
        \( -iname '*.otf' -o -iname '*.otc' -o -iname '*.ttf' -o -iname '*.ttc' \) \
        -print0
    )

    for index in "''${!font_paths[@]}"; do
      font=''${font_paths[$index]}
      font_name=''${font_names[$index]}
      font_style=''${font_styles[$index]}

      if [ "''${family_counts[$font_name]}" -gt 1 ] && [ -n "$font_style" ]; then
        font_name="$font_name $font_style"
      fi

      if should_skip_font "$scope" "$pname" "$font_name"; then
        continue
      fi

      image=$scope_dir/$pname+$font_name.png
      image_key=$pname+$font_name
      image_count=''${image_counts[$image_key]:-0}
      image_counts["$image_key"]=$((image_count + 1))

      if [ "$image_count" -gt 0 ]; then
        image=$scope_dir/$pname+$font_name-$((image_count + 1)).png
      fi

      if [ "$override" = false ] && [ -e "$image" ]; then
        continue
      fi

      sample=$(choose_sample "$sample_key" "$font_name")
      temporary_image=$(mktemp "$scope_dir/.preview.XXXXXX.png")

      render_with_magick "$font" "$temporary_image" "$sample"

      if is_blank_image "$temporary_image"; then
        rm -f "$temporary_image"
        temporary_image=$(mktemp "$scope_dir/.preview.XXXXXX.png")
        render_with_pango \
          "$fontconfig_file" \
          "$font_name" \
          "$temporary_image" \
          "$sample"
      fi

      if is_blank_image "$temporary_image"; then
        rm -f "$temporary_image"
        continue
      fi

      mv -f "$temporary_image" "$image"

      printf '%s\n' "$image"
    done

    rm -f "$fontconfig_file"
  done < ${fontPreviewManifest}
'').overrideAttrs
  (_: {
    meta = {
      description = "Generate preview PNGs for Chinese font packages";
      license = licenses.cc0;
      mainProgram = "generate-font-preview-images";
      maintainers = with maintainers; [ brsvh ];
    };

    passthru = {
      manifest = fontPreviewManifest;
    };
  })
