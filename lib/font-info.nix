{
  lib,
  ...
}:
let
  inherit (lib)
    all
    assertMsg
    attrNames
    elem
    isAttrs
    isBool
    isList
    isString
    lessThan
    match
    removeAttrs
    sort
    unique
    ;

  licenseCosts = {
    commercialFree = "商业免费使用";
    none = "无许可费";
    paid = "付费使用";
    personalFree = "个人免费使用";
  };

  noticeLevels = {
    caution = "警示";
    important = "重要";
    note = "说明";
    tip = "提示";
    warning = "警告";
  };

  styles = {
    art = "艺术字体";
    cal = "书法字体";
    fangsong = "仿宋";
    handwritten = "手写体";
    hei = "黑体";
    kai = "楷体";
    li = "隶书";
    rounded = "圆体";
    sans = "无衬线体";
    serif = "衬线体";
    song = "宋体";
    symbol = "符号字体";
    unknown = "未知";
  };

  vendors = {
    alibaba = "Alibaba Design（阿里巴巴）";
    alimama = "Alimama（阿里妈妈）";
    buttaiwan = "ZiHi（字嗨）";
    cwtex = "cwTeX Q";
    dingtalk = "DingTalk（钉钉）";
    foundertype = "FounderType（方正字库）";
    hanwang = "H.T.Wang Free Fonts（王漢宗自由字型）";
    huawei = "Huawei（华为）";
    ichitenfont = "I.字坊／刻石錄";
    ito = "糸 FONT";
    jikasei = "自家製フォント工房";
    justfont = "justfont";
    lingdong = "LingDong Huang（令東）";
    lxgw = "LXGW（落霞孤鹜）";
    microsoft = "Microsoft（微软）";
    naver = "NAVER";
    oppo = "OPPO";
    tanuki = "たぬきフォント";
    taobao = "Taobao（淘宝）";
    tianheng = "TianHeng（天珩字库）";
    trionestype = "TrionesType（璇璣造字）";
    tsangertype = "TsangerType（仓耳字库）";
    xiaomi = "Xiaomi（小米）";
  };

  stringList =
    value: isList value && all isString value;
  ordered =
    values: values == sort lessThan (unique values);

  validNotice =
    notice:
    isAttrs notice
    &&
      attrNames (removeAttrs notice [ "url" ]) == [
        "level"
        "text"
      ]
    && isString notice.level
    && noticeLevels ? ${notice.level}
    && isString notice.text
    && match "[[:space:]]*" notice.text == null
    && (
      !(notice ? url)
      || (
        isString notice.url
        &&
          match "https?://[^[:space:]]+" notice.url != null
      )
    );

  validate =
    id: info:
    assert assertMsg
      (
        isAttrs info
        &&
          attrNames (
            removeAttrs info [
              "embedding"
              "notices"
            ]
          ) == [
            "displayName"
            "languages"
            "licenseCost"
            "styles"
            "vendor"
          ]
      )
      "${id}: chinese-fonts-overlay-site must declare displayName, languages, licenseCost, styles, and vendor; embedding and notices are optional";
    assert assertMsg
      (!(info ? embedding) || isBool info.embedding)
      "${id}: chinese-fonts-overlay-site.embedding must be a boolean";
    assert assertMsg
      (
        isString info.displayName
        && match "[[:space:]]*" info.displayName == null
      )
      "${id}: chinese-fonts-overlay-site.displayName must be a nonempty string";
    assert assertMsg
      (
        isList (info.notices or [ ])
        && all validNotice (info.notices or [ ])
      )
      "${id}: chinese-fonts-overlay-site.notices must be a list of level/text entries with a registered level, nonempty text, and an optional HTTP(S) url";
    assert assertMsg
      (
        isString info.licenseCost
        && licenseCosts ? ${info.licenseCost}
      )
      "${id}: chinese-fonts-overlay-site.licenseCost must be none, commercialFree, personalFree, or paid";
    assert assertMsg
      (isString info.vendor && vendors ? ${info.vendor})
      "${id}: chinese-fonts-overlay-site.vendor must name a registered vendor";
    assert assertMsg
      (
        stringList info.languages
        && ordered info.languages
        && all (
          tag:
          match "[a-z]{2,3}(-[a-z0-9]{2,8})*" tag != null
        ) info.languages
      )
      "${id}: chinese-fonts-overlay-site.languages must be a sorted, unique list of Fontconfig language tags";
    assert assertMsg
      (
        stringList info.styles
        && info.styles != [ ]
        && ordered info.styles
        && all (style: styles ? ${style}) info.styles
        && (
          info.styles == [ "unknown" ]
          || !(elem "unknown" info.styles)
        )
      )
      "${id}: chinese-fonts-overlay-site.styles must be sorted, unique registered styles; unknown must stand alone";
    info;
in
{
  inherit
    licenseCosts
    noticeLevels
    styles
    validate
    vendors
    ;
}
