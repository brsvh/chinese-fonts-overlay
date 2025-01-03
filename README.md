# Chinese fonts overlay

这个仓库用于提供一些中文字体的收集，以 nix packages 的形式提供构建。

## 简介

这个仓库目前提供了以下公司、字库的若干产品的构建方式：

- Alibaba 字体
- FounderType 字体
- TH 字体
- TrionesType 字体
- TsangerType 字体
- Microsoft 字体

> [!CAUTION]
> 
> 这个仓库包含一些不可再分发的字体，请你在购买相关许可后进行本地构建和安装，或在学习、交流后从本地 store 中移除下列字体：
>  - FounderType （方正字库）版权所有的字体；
>  - Microsoft Corporation, Inc. （微软公司）版权所有或其分发的字体；
>  - TH 字体 (天珩字库) ；
>  - TsangerType （仓耳字库）中未以仓耳字库免费商用字体授权声明 [^1] 许可的字体；
> 特殊的，仓耳字库免费商用字体授权声明 [^1] 中使用了“免费开源字体”等字
> 样，但其源代码无法获取。

## 开始上手

你只需要将此仓库的 overlay 添加至你的配置中然后安装期望的字体即可。

``` nix
{
  inputs = {
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chinese-fonts-overlay.url = "github:brsvh/chinese-fonts-overlays/main";
  };

  output = inputs:
    {
      homeConfigurations.YOUR-CONFIGURATION-NAME = inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  inputs.chinese-fonts-overlay.overlays.default # 所有字体
                ];
              };
              home.packages = with pkgs; [
                alibaba-fonts # 所有阿里巴巴普惠体
                alibabaFonts.puhuiti-3 # 阿里巴巴普惠体 3.0
                # ...
              ];
            }
          )
        ];
      };

      nixosConfigurations.YOUR-CONFIGURATOIN-NAME = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  inputs.chinese-fonts-overlay.overlays.default # 所有字体
                ];
              };
              fonts.packages = with pkgs; [
                alibaba-fonts # 所有阿里巴巴普惠体
                alibabaFonts.puhuiti-3 # 阿里巴巴普惠体 3.0
                # ...
              ];
            }
          )
        ];
      };
    };
}
```

### 排除一部分字体

`alibabaFonts`、`foundertypeFonts`、`trionestypeFonts`、`tsangertypeFonts` 这些 scope 均提供了 `combine` 和 `combine'` 来方便你创建满足自定义条件的字体集。

#### `<scope>.combine`

`combine :: (Derivation -> Bool) -> Derivation` 接收一个 `cond` 条件函数，用于过滤 `<scope>` 中的所有派生满足给定条件的那些。

#### `<scope>.combine'`

`combine :: String -> (Derivation -> Bool) -> Derivation` 接收一个 `name` 作为最终字体集合派生的 `pname`，和一个 `cond`，它和 `<scope>.combine` 的 `cond` 相同。

## 提供的字体

### Alibaba Fonts

| 包                       | 字体               |
|--------------------------|--------------------|
| `alibabaFonts.puhuiti-2` | 阿里巴巴普惠体 2.0 |
| `alibabaFonts.puhuiti-3` | 阿里巴巴普惠体 3.0 |

### FounderType Fonts

`foundertype-fonts` 提供在 CTeX 的 `founder` fontset 依赖的字体，它们有两种情形。

1. 免费字体，在方正商业授权[^2] 和 方正个人非商业授权 [^3] 下可以免费获得的字体。
2. 付费字体，需要额外进行购买使用和商业发布授权的字体。

这两种情形，您均需要在方正字库官网获得这些字体的授权后进行使用。

> [!NOTE]
>
> 方正字库的许可条款较多，请您仔细阅读。如果不想阅读，以下的做法通常不会给您带来法律问题：
>  - 在购买授权许可后，仅在本地机器用作屏幕显示字体；
>  - 在购买授权许可后，对使用它们字体创建的文档，不要进行发布和分享；
> 除此之外的使用场景，您需要仔细阅读相关授权条款自行判断。

#### 免费字体

| 包                       | 字体     |
|--------------------------|----------|
| `foundertypeFonts.fzfsk` | 方正仿宋 |
| `foundertypeFonts.fzhtk` | 方正黑体 |
| `foundertypeFonts.fzktk` | 方正楷体 |
| `foundertypeFonts.fzssk` | 方正书宋 |

只安装它们：

``` nix
foundertypeFonts.combine (
  font:
  (lib.attrByPath [
    "meta"
    "license"
    "shortName"
  ] "unknown" font) == "foundertype-per-ula"
)
```

#### 付费字体

> [!CAUTION]
> 
> 下列的字体均需要付费获取授权，请您在使用前在方正字库官方网站购买这些字体的使用授权后再在本地进行构建。否则您需要自行承担相关的法律风险。

| 包                       | 字体     |
|--------------------------|----------|
| `foundertypeFonts.fzlsk` | 方正隶书 |
| `foundertypeFonts.fzxbsk` | 方正小标宋 |
| `foundertypeFonts.fzxh1k` | 方正细黑 |
| `foundertypeFonts.fzy1k` | 方正细圆一 |
| `foundertypeFonts.fzy3k` | 方正准圆 |
| `foundertypeFonts.fzy4k` | 方正粗体 |

### Microsoft Fonts

`windows-fonts` 提供构建 Windows 11 默认集成的所有字体。

> [!CAUTION]
>
> 您不能在非 Windows 设备上使用它们。

### TH Fonts

> [!CAUTION]
>
> 天珩字库中字体的字形来自中易、华康、Iwata、Besta、方正等公司，其字体使用必须用于非盈利、学习研究的用途。[^4]
>
> 其具体的版权问题比较复杂，建议仅做本地屏显用途。

`TH-fonts` 是所有字体的链接。

| 包           | 字体          |
|--------------|---------------|
| `THFonts.Hak`     | 天珩字库-黑体 |
| `THFonts.Joeng`   | 天珩字库-阳明 |
| `THFonts.Khaai-P` | 天珩字库-正楷 |
| `THFonts.Khaai-T` | 天珩字库-标楷 |
| `THFonts.Ming`    | 天珩字库-花园 |
| `THFonts.Sung-P`  | 天珩字库-正宋 |
| `THFonts.Sung-T`  | 天珩字库-标宋 |
| `THFonts.Sy`      | 天珩字库-书宋 |
| `THFonts.Tshyn`   | 天珩全字库    |

### TrionesType Fonts

`trionestype-fonts` 是所有字体的链接。

| 包                                | 字体     |
|-----------------------------------|----------|
| `trionestypeFonts.ZhuqueFangsong` | 朱雀仿宋 |

### Tsangertype Fonts

`tsangertype-fonts` 是所有字体的链接。

安装它们中的一部分：

``` nix
tsangertypeFonts.combine (
  font:
  builtins.elem font.pname [
    "tsangertype-feibai-w01"
    "tsangertype-feibai-w03"
    "tsangertype-feibai-w05"
  ]
)
```

#### 免费商用

`tsangertype-gcc-fonts` （这里的 `gcc` 是 *gratis propria commercium*，区别于 *free*）是下列所有免费商用字体的链接。

> [!NOTE]
> 仓耳字库免费商用字体授权声明[^3]中使用了“免费开源字体”等字样，但我未找到其源代码。

| 包                                      | 字体             |
|-----------------------------------------|------------------|
| `tsangertypeFonts.feibai-w01`           | 仓耳非白W01      |
| `tsangertypeFonts.feibai-w02`           | 仓耳非白W02      |
| `tsangertypeFonts.feibai-w03`           | 仓耳非白W03      |
| `tsangertypeFonts.feibai-w04`           | 仓耳非白W04      |
| `tsangertypeFonts.feibai-w05`           | 仓耳非白W05      |
| `tsangertypeFonts.shuyuan-w01`          | 仓耳舒圆体W01    |
| `tsangertypeFonts.shuyuan-w02`          | 仓耳舒圆体W02    |
| `tsangertypeFonts.shuyuan-w03`          | 仓耳舒圆体W03    |
| `tsangertypeFonts.shuyuan-w04`          | 仓耳舒圆体W04    |
| `tsangertypeFonts.shuyuan-w05`          | 仓耳舒圆体W05    |
| `tsangertypeFonts.xiaowanzi`            | 仓耳小丸子       |
| `tsangertypeFonts.yumo-w01`             | 仓耳与墨W01      |
| `tsangertypeFonts.yumo-w02`             | 仓耳与墨W02      |
| `tsangertypeFonts.yumo-w03`             | 仓耳与墨W03      |
| `tsangertypeFonts.yumo-w04`             | 仓耳与墨W04      |
| `tsangertypeFonts.yumo-w05`             | 仓耳与墨W05      |
| `tsangertypeFonts.yuyang-w01`           | 仓耳渔阳体W01    |
| `tsangertypeFonts.yuyang-w02`           | 仓耳渔阳体W02    |
| `tsangertypeFonts.yuyang-w03`           | 仓耳渔阳体W03    |
| `tsangertypeFonts.yuyang-w04`           | 仓耳渔阳体W04    |
| `tsangertypeFonts.yuyang-w05`           | 仓耳渔阳体W05    |
| `tsangertypeFonts.zhoukezhengdabangshu` | 仓耳周珂正大榜书 |

#### 个人非商用

`tsangertype-gcp-fonts` （这里的 `gcp` 是指 *gratis propria persona*）是下列所有个人非商用字体的链接。

| 包                                             | 字体                   |
|------------------------------------------------|------------------------|
| `tsangertypeFonts.aidekunkun`                  | 仓耳爱的坤坤体         |
| `tsangertypeFonts.aiminxiaokai`                | 仓耳爱民小楷           |
| `tsangertypeFonts.aiminxingkai`                | 仓耳爱民行楷           |
| `tsangertypeFonts.aiminxingshu`                | 仓耳爱民行书           |
| `tsangertypeFonts.ainimengmengda`              | 仓耳爱你萌萌哒         |
| `tsangertypeFonts.aiqinglianxisheng`           | 仓耳爱情练习生         |
| `tsangertypeFonts.babilong`                    | 仓耳吧吡咙体           |
| `tsangertypeFonts.bailing-w01`                 | 仓耳百灵W01            |
| `tsangertypeFonts.bailing-w02`                 | 仓耳百灵W02            |
| `tsangertypeFonts.bailing-w03`                 | 仓耳百灵W03            |
| `tsangertypeFonts.bailing-w04`                 | 仓耳百灵W04            |
| `tsangertypeFonts.bailing-w05`                 | 仓耳百灵W05            |
| `tsangertypeFonts.banghei`                     | 仓耳榜黑               |
| `tsangertypeFonts.bantangshouzha`              | 仓耳半糖手札           |
| `tsangertypeFonts.benmiaozaici`                | 仓耳本喵在此体         |
| `tsangertypeFonts.cangermuxi`                  | 仓耳木兮体             |
| `tsangertypeFonts.caolulinshouji`              | 仓耳曹录林手迹         |
| `tsangertypeFonts.caozhebinjunxiukaishu`       | 仓耳曹哲斌俊秀楷书     |
| `tsangertypeFonts.caozhebinjunxiukaishu-bold`  | 仓耳曹哲斌俊秀楷书加粗 |
| `tsangertypeFonts.caozhebinkaishu`             | 仓耳曹哲斌楷书         |
| `tsangertypeFonts.caozhebinkaishu-bold`        | 仓耳曹哲斌楷书加粗     |
| `tsangertypeFonts.caozhebinlingyunkaishu`      | 仓耳曹哲斌灵韵楷书     |
| `tsangertypeFonts.caozhebinlingyunkaishu-bold` | 仓耳曹哲斌灵韵楷书加粗 |
| `tsangertypeFonts.caozhebinxingkai`            | 仓耳曹哲斌行楷         |
| `tsangertypeFonts.chengshishangkongdefanxing`  | 城市上空的繁星体       |
| `tsangertypeFonts.chuangyi-w01`                | 仓耳创意体W01          |
| `tsangertypeFonts.chuangyi-w02`                | 仓耳创意体W02          |
| `tsangertypeFonts.chuangyi-w03`                | 仓耳创意体W03          |
| `tsangertypeFonts.chunfeng`                    | 仓耳春风体             |
| `tsangertypeFonts.chuyu`                       | 仓耳初遇体             |
| `tsangertypeFonts.daimengxiaomutou`            | 仓耳呆萌小木头体       |
| `tsangertypeFonts.dainiushouxie`               | 呆牛手写体             |
| `tsangertypeFonts.daji`                        | 仓耳大吉体             |
| `tsangertypeFonts.damanman-w01`                | 仓耳大漫漫体W01        |
| `tsangertypeFonts.damanman-w02`                | 仓耳大漫漫体W02        |
| `tsangertypeFonts.damanman-w03`                | 仓耳大漫漫体W03        |
| `tsangertypeFonts.damanman-w04`                | 仓耳大漫漫体W04        |
| `tsangertypeFonts.damanman-w05`                | 仓耳大漫漫体W05        |
| `tsangertypeFonts.daofengzhanshi`              | 刀锋战士体             |
| `tsangertypeFonts.daofengzhanshi-bold`         | 刀锋战士粗体           |
| `tsangertypeFonts.dianshichengjin`             | 仓耳点石成金体         |
| `tsangertypeFonts.diewu`                       | 仓耳蝶舞体             |
| `tsangertypeFonts.diyiyanaishangni`            | 仓耳第一眼爱上你       |
| `tsangertypeFonts.dubai`                       | 仓耳独白体             |
| `tsangertypeFonts.dudu-w01`                    | 仓耳嘟嘟体W01          |
| `tsangertypeFonts.dudu-w02`                    | 仓耳嘟嘟体W02          |
| `tsangertypeFonts.dudu-w03`                    | 仓耳嘟嘟体W03          |
| `tsangertypeFonts.dudu-w04`                    | 仓耳嘟嘟体W04          |
| `tsangertypeFonts.fanghei`                     | 仓耳方黑               |
| `tsangertypeFonts.feifei-w01`                  | 仓耳飞飞体W01          |
| `tsangertypeFonts.feifei-w02`                  | 仓耳飞飞体W02          |
| `tsangertypeFonts.feifei-w03`                  | 仓耳飞飞体W03          |
| `tsangertypeFonts.feifei-w04`                  | 仓耳飞飞体W04          |
| `tsangertypeFonts.feiteng`                     | 仓耳沸腾体             |
| `tsangertypeFonts.fengerchui`                  | 仓耳风儿吹             |
| `tsangertypeFonts.fenghei`                     | 仓耳丰黑               |
| `tsangertypeFonts.fengwujiutian-w01`           | 仓耳锋舞九天W01        |
| `tsangertypeFonts.fengwujiutian-w02`           | 仓耳锋舞九天W02        |
| `tsangertypeFonts.fengwujiutian-w03`           | 仓耳锋舞九天W03        |
| `tsangertypeFonts.fengwujiutian-w04`           | 仓耳锋舞九天W04        |
| `tsangertypeFonts.fengwujiutian-w05`           | 仓耳锋舞九天W05        |
| `tsangertypeFonts.fengwujiutian-w06`           | 仓耳锋舞九天W06        |
| `tsangertypeFonts.fengyun-w01`                 | 仓耳锋韵W01            |
| `tsangertypeFonts.fengyun-w02`                 | 仓耳锋韵W02            |
| `tsangertypeFonts.fengyun-w03`                 | 仓耳锋韵W03            |
| `tsangertypeFonts.fengyun-w04`                 | 仓耳锋韵W04            |
| `tsangertypeFonts.fengyun-w05`                 | 仓耳锋韵W05            |
| `tsangertypeFonts.fengyun-w06`                 | 仓耳锋韵W06            |
| `tsangertypeFonts.fengyun-w07`                 | 仓耳锋韵W07            |
| `tsangertypeFonts.gexingtuya`                  | 仓耳个性涂鸦体         |
| `tsangertypeFonts.guateng`                     | 仓耳瓜藤体             |
| `tsangertypeFonts.gufengkaishu`                | 仓耳古风楷书           |
| `tsangertypeFonts.gufengxingshu`               | 仓耳古风行书           |
| `tsangertypeFonts.guli-w01`                    | 仓耳谷力W01            |
| `tsangertypeFonts.guli-w02`                    | 仓耳谷力W02            |
| `tsangertypeFonts.guli-w03`                    | 仓耳谷力W03            |
| `tsangertypeFonts.guli-w04`                    | 仓耳谷力W04            |
| `tsangertypeFonts.guli-w05`                    | 仓耳谷力W05            |
| `tsangertypeFonts.guodongxixi`                 | 仓耳果冻吸吸体         |
| `tsangertypeFonts.guyun`                       | 仓耳古韵体             |
| `tsangertypeFonts.haloutuxiansheng`            | 仓耳哈喽兔先生体       |
| `tsangertypeFonts.hanshan`                     | 仓耳寒山体             |
| `tsangertypeFonts.hefeng`                      | 仓耳荷风体             |
| `tsangertypeFonts.huaxin`                      | 仓耳华新体             |
| `tsangertypeFonts.huayu`                       | 仓耳花语               |
| `tsangertypeFonts.jiaotangmaqiduo`             | 仓耳焦糖玛奇朵体       |
| `tsangertypeFonts.jiaxuan`                     | 仓耳佳轩体             |
| `tsangertypeFonts.jiekou`                      | 仓耳结扣体             |
| `tsangertypeFonts.jiemo`                       | 仓耳芥末体             |
| `tsangertypeFonts.jingya`                      | 仓耳静雅体             |
| `tsangertypeFonts.jinkai01-w01`                | 仓耳今楷01-W01         |
| `tsangertypeFonts.jinkai01-w02`                | 仓耳今楷01-W02         |
| `tsangertypeFonts.jinkai01-w03`                | 仓耳今楷01-W03         |
| `tsangertypeFonts.jinkai01-w04`                | 仓耳今楷01-W04         |
| `tsangertypeFonts.jinkai01-w05`                | 仓耳今楷01-W05         |
| `tsangertypeFonts.jinkai02-w01`                | 仓耳今楷02-W01         |
| `tsangertypeFonts.jinkai02-w02`                | 仓耳今楷02-W02         |
| `tsangertypeFonts.jinkai02-w03`                | 仓耳今楷02-W03         |
| `tsangertypeFonts.jinkai02-w04`                | 仓耳今楷02-W04         |
| `tsangertypeFonts.jinkai02-w05`                | 仓耳今楷02-W05         |
| `tsangertypeFonts.jinkai03-w01`                | 仓耳今楷03-W01         |
| `tsangertypeFonts.jinkai03-w02`                | 仓耳今楷03-W02         |
| `tsangertypeFonts.jinkai03-w03`                | 仓耳今楷03-W03         |
| `tsangertypeFonts.jinkai03-w04`                | 仓耳今楷03-W04         |
| `tsangertypeFonts.jinkai03-w05`                | 仓耳今楷03-W05         |
| `tsangertypeFonts.jinkai04-w01`                | 仓耳今楷04-W01         |
| `tsangertypeFonts.jinkai04-w02`                | 仓耳今楷04-W02         |
| `tsangertypeFonts.jinkai04-w03`                | 仓耳今楷04-W03         |
| `tsangertypeFonts.jinkai04-w04`                | 仓耳今楷04-W04         |
| `tsangertypeFonts.jinkai04-w05`                | 仓耳今楷04-W05         |
| `tsangertypeFonts.jinkai05-w01`                | 仓耳今楷05-W01         |
| `tsangertypeFonts.jinkai05-w02`                | 仓耳今楷05-W02         |
| `tsangertypeFonts.jinkai05-w03`                | 仓耳今楷05-W03         |
| `tsangertypeFonts.jinkai05-w04`                | 仓耳今楷05-W04         |
| `tsangertypeFonts.jinkai05-w05`                | 仓耳今楷05-W05         |
| `tsangertypeFonts.jinshirongyao`               | 仓耳金石荣耀体         |
| `tsangertypeFonts.jundongkaishu`               | 仓耳俊冬楷书           |
| `tsangertypeFonts.jundongxingshu`              | 仓耳俊冬行书           |
| `tsangertypeFonts.juzhenchangfang`             | 仓耳聚珍长仿           |
| `tsangertypeFonts.juziwei`                     | 仓耳橘子味             |
| `tsangertypeFonts.keke`                        | 仓耳柯柯体             |
| `tsangertypeFonts.konglukaishu`                | 仓耳孔璐楷书           |
| `tsangertypeFonts.kuhei`                       | 仓耳酷黑               |
| `tsangertypeFonts.lankai`                      | 仓耳兰楷               |
| `tsangertypeFonts.leizhenhanfeng`              | 仓耳雷震汉风体         |
| `tsangertypeFonts.lekeke`                      | 仓耳乐可可体           |
| `tsangertypeFonts.lelebiji`                    | 乐乐笔记体             |
| `tsangertypeFonts.lezhi`                       | 仓耳乐志体             |
| `tsangertypeFonts.lianaibiji`                  | 仓耳恋爱笔记体         |
| `tsangertypeFonts.lifei`                       | 仓耳利飞体             |
| `tsangertypeFonts.linggang-w01`                | 仓耳凌刚体W01          |
| `tsangertypeFonts.linggang-w02`                | 仓耳凌刚体W02          |
| `tsangertypeFonts.linggang-w03`                | 仓耳凌刚体W03          |
| `tsangertypeFonts.linggang-w04`                | 仓耳凌刚体W04          |
| `tsangertypeFonts.linggang-w05`                | 仓耳凌刚体W05          |
| `tsangertypeFonts.lingyun`                     | 仓耳凌云体             |
| `tsangertypeFonts.lishi`                       | 仓耳力士体             |
| `tsangertypeFonts.liyuan`                      | 仓耳丽圆               |
| `tsangertypeFonts.manmiao`                     | 仓耳曼妙体             |
| `tsangertypeFonts.maobohe`                     | 仓耳猫薄荷体           |
| `tsangertypeFonts.meixin-w01`                  | 仓耳美心体W01          |
| `tsangertypeFonts.meixin-w02`                  | 仓耳美心体W02          |
| `tsangertypeFonts.mengbaokeji`                 | 仓耳萌宝柯基体         |
| `tsangertypeFonts.mengdaimiaowei`              | 仓耳萌呆喵尾体         |
| `tsangertypeFonts.mengdie`                     | 仓耳梦蝶体             |
| `tsangertypeFonts.mengduoduo`                  | 仓耳萌朵朵体           |
| `tsangertypeFonts.mengmengdaxiaodouzi`         | 萌萌哒小豆子体         |
| `tsangertypeFonts.mengmiaojiang`               | 仓耳萌喵酱             |
| `tsangertypeFonts.mengtonglishu`               | 仓耳梦桐隶书           |
| `tsangertypeFonts.mengxingdelibie`             | 仓耳梦醒的离别体       |
| `tsangertypeFonts.minghei-w01`                 | 仓耳明黑W01            |
| `tsangertypeFonts.minghei-w02`                 | 仓耳明黑W02            |
| `tsangertypeFonts.minghei-w03`                 | 仓耳明黑W03            |
| `tsangertypeFonts.minghei-w04`                 | 仓耳明黑W04            |
| `tsangertypeFonts.minghei-w05`                 | 仓耳明黑W05            |
| `tsangertypeFonts.minghei-w06`                 | 仓耳明黑W06            |
| `tsangertypeFonts.minghei-w07`                 | 仓耳明黑W07            |
| `tsangertypeFonts.minghei-w08`                 | 仓耳明黑W08            |
| `tsangertypeFonts.mingkai-w01`                 | 仓耳明楷W01            |
| `tsangertypeFonts.mingkai-w02`                 | 仓耳明楷W02            |
| `tsangertypeFonts.mingkai-w03`                 | 仓耳明楷W03            |
| `tsangertypeFonts.mingkai-w04`                 | 仓耳明楷W04            |
| `tsangertypeFonts.mingyue`                     | 仓耳明月体             |
| `tsangertypeFonts.mizhiguo`                    | 仓耳秘之果             |
| `tsangertypeFonts.mocha`                       | 仓耳抹茶体             |
| `tsangertypeFonts.nihaoshiguang`               | 仓耳你好时光体         |
| `tsangertypeFonts.nishiwodequanshijie`         | 你是我的全世界         |
| `tsangertypeFonts.nishiwoweiyi`                | 仓耳你是我唯一         |
| `tsangertypeFonts.nuannanshouzha`              | 仓耳暖男手札体         |
| `tsangertypeFonts.nuanxin`                     | 仓耳暖心体             |
| `tsangertypeFonts.nvwang`                      | 仓耳女王体             |
| `tsangertypeFonts.peiban`                      | 仓耳陪伴体             |
| `tsangertypeFonts.piaomiao`                    | 仓耳缥缈体             |
| `tsangertypeFonts.qiaole-w01`                  | 仓耳巧乐W01            |
| `tsangertypeFonts.qiaole-w02`                  | 仓耳巧乐W02            |
| `tsangertypeFonts.qiaole-w03`                  | 仓耳巧乐W03            |
| `tsangertypeFonts.qiaole-w04`                  | 仓耳巧乐W04            |
| `tsangertypeFonts.qiaole-w05`                  | 仓耳巧乐W05            |
| `tsangertypeFonts.qiedoudou`                   | 仓耳企鹅豆豆体         |
| `tsangertypeFonts.qiming`                      | 仓耳启明体             |
| `tsangertypeFonts.qingchunyiniweiming`         | 仓耳青春以你为名体     |
| `tsangertypeFonts.qingfeng`                    | 仓耳清风体             |
| `tsangertypeFonts.qingfengxieyang`             | 仓耳轻风斜阳体         |
| `tsangertypeFonts.qinghe-w01`                  | 仓耳青禾体W01          |
| `tsangertypeFonts.qinghe-w02`                  | 仓耳青禾体W02          |
| `tsangertypeFonts.qinghe-w03`                  | 仓耳青禾体W03          |
| `tsangertypeFonts.qinghe-w04`                  | 仓耳青禾体W04          |
| `tsangertypeFonts.qinghe-w05`                  | 仓耳青禾体W05          |
| `tsangertypeFonts.qinghuan`                    | 仓耳清欢体             |
| `tsangertypeFonts.qingji`                      | 仓耳青吉体             |
| `tsangertypeFonts.qingmei`                     | 仓耳青梅体             |
| `tsangertypeFonts.qingning`                    | 仓耳青柠体             |
| `tsangertypeFonts.qingqiuxiaojiu`              | 仓耳青丘小九           |
| `tsangertypeFonts.qingque`                     | 仓耳青雀体             |
| `tsangertypeFonts.qingsong`                    | 仓耳青宋               |
| `tsangertypeFonts.qingxin`                     | 仓耳晴心体             |
| `tsangertypeFonts.qingya-fang`                 | 仓耳青雅-方            |
| `tsangertypeFonts.qingya-yuan`                 | 仓耳青雅-圆            |
| `tsangertypeFonts.qingyou`                     | 仓耳轻悠体             |
| `tsangertypeFonts.qinqinmeizhuang`             | 亲亲美妆体             |
| `tsangertypeFonts.qiuyue`                      | 仓耳秋月体             |
| `tsangertypeFonts.quancunzuikeai`              | 仓耳全村最可爱         |
| `tsangertypeFonts.quhei`                       | 仓耳趣黑               |
| `tsangertypeFonts.rouhei`                      | 仓耳柔黑               |
| `tsangertypeFonts.ruihei`                      | 仓耳锐黑               |
| `tsangertypeFonts.runhei-w01`                  | 仓耳润黑W01            |
| `tsangertypeFonts.runhei-w02`                  | 仓耳润黑W02            |
| `tsangertypeFonts.runhei-w03`                  | 仓耳润黑W03            |
| `tsangertypeFonts.shangshanruoshui`            | 仓耳上善若水           |
| `tsangertypeFonts.shenniaoxinshengchuangyi`    | 神鸟新生创意体         |
| `tsangertypeFonts.shenqidedoudou`              | 仓耳神奇的豆豆体       |
| `tsangertypeFonts.shuhei`                      | 仓耳曙黑               |
| `tsangertypeFonts.sirou`                       | 仓耳丝柔体             |
| `tsangertypeFonts.siyaoxingkai`                | 仓耳丝摇行楷           |
| `tsangertypeFonts.siyecaodexingfu`             | 仓耳四叶草的幸福体     |
| `tsangertypeFonts.songguo`                     | 松果体                 |
| `tsangertypeFonts.songkai`                     | 仓耳宋楷               |
| `tsangertypeFonts.suxin`                       | 仓耳苏心体             |
| `tsangertypeFonts.tianmimi`                    | 仓耳甜蜜蜜体           |
| `tsangertypeFonts.tianmu-w01`                  | 仓耳天沐体W01          |
| `tsangertypeFonts.tianmu-w02`                  | 仓耳天沐体W02          |
| `tsangertypeFonts.tianmu-w03`                  | 仓耳天沐体W03          |
| `tsangertypeFonts.tianmu-w04`                  | 仓耳天沐体W04          |
| `tsangertypeFonts.tianmu-w05`                  | 仓耳天沐体W05          |
| `tsangertypeFonts.tianqunxingkai`              | 仓耳天群行楷           |
| `tsangertypeFonts.tiansuolele`                 | 仓耳天锁乐乐体         |
| `tsangertypeFonts.tingfeng`                    | 仓耳听风体             |
| `tsangertypeFonts.tongzhuo`                    | 仓耳同桌体             |
| `tsangertypeFonts.tuya-w01`                    | 仓耳涂鸦体W01          |
| `tsangertypeFonts.tuya-w02`                    | 仓耳涂鸦体W02          |
| `tsangertypeFonts.tuya-w03`                    | 仓耳涂鸦体W03          |
| `tsangertypeFonts.wandongxingshu`              | 仓耳万东行书           |
| `tsangertypeFonts.weilairiji`                  | 未来日记体             |
| `tsangertypeFonts.wugexingbuqingchun`          | 仓耳无个性不青春体     |
| `tsangertypeFonts.wuliangshoufu`               | 仓耳无量寿福体         |
| `tsangertypeFonts.xiangzuozouxiangyouzou`      | 仓耳向左走向右走体     |
| `tsangertypeFonts.xiaobaikaishu`               | 仓耳小白楷书           |
| `tsangertypeFonts.xiaobaiwan`                  | 仓耳小百万             |
| `tsangertypeFonts.xiaobaixingshu`              | 仓耳小白行书           |
| `tsangertypeFonts.xiaodianer`                  | 仓耳小点儿体           |
| `tsangertypeFonts.xiaofang`                    | 仓耳小方体             |
| `tsangertypeFonts.xiaokeai-w01`                | 仓耳小可爱体W01        |
| `tsangertypeFonts.xiaokeai-w02`                | 仓耳小可爱体W02        |
| `tsangertypeFonts.xiaokeai-w03`                | 仓耳小可爱体W03        |
| `tsangertypeFonts.xiaokeai-w04`                | 仓耳小可爱体W04        |
| `tsangertypeFonts.xiaokeai-w05`                | 仓耳小可爱体W05        |
| `tsangertypeFonts.xiaokeai-w06`                | 仓耳小可爱体W06        |
| `tsangertypeFonts.xiaomanman-w01`              | 仓耳小漫漫体W01        |
| `tsangertypeFonts.xiaomanman-w02`              | 仓耳小漫漫体W02        |
| `tsangertypeFonts.xiaomanman-w03`              | 仓耳小漫漫体W03        |
| `tsangertypeFonts.xiaomanman-w04`              | 仓耳小漫漫体W04        |
| `tsangertypeFonts.xiaomanman-w05`              | 仓耳小漫漫体W05        |
| `tsangertypeFonts.feigexiaosaxingshu`          | 飞哥潇洒行书           |
| `tsangertypeFonts.xiaoshipin`                  | 仓耳小视频体           |
| `tsangertypeFonts.xiaowoniudemeng`             | 仓耳小蜗牛的梦         |
| `tsangertypeFonts.xiaoxiaohuochai`             | 仓耳小小火柴体         |
| `tsangertypeFonts.xiaoxiaomangguo`             | 仓耳小小芒果体         |
| `tsangertypeFonts.xiaoyaoxingshu`              | 仓耳逍遥行书           |
| `tsangertypeFonts.xiaoyashouji`                | 仓耳小雅手迹           |
| `tsangertypeFonts.xiaoyutongxue`               | 仓耳小雨同学体         |
| `tsangertypeFonts.xiayizhanxingfu`             | 仓耳下一站幸福体       |
| `tsangertypeFonts.xingchenkaishu`              | 仓耳星辰楷书           |
| `tsangertypeFonts.xingfuyuezhang`              | 仓耳幸福乐章体         |
| `tsangertypeFonts.xinghansong`                 | 仓耳星汉宋             |
| `tsangertypeFonts.xinxing`                     | 仓耳心星体             |
| `tsangertypeFonts.xinyan`                      | 仓耳新颜体             |
| `tsangertypeFonts.xinyue01`                    | 仓耳新悦体             |
| `tsangertypeFonts.xinyue02`                    | 仓耳欣月体             |
| `tsangertypeFonts.xiuxianxingshu`              | 仓耳绣线行书           |
| `tsangertypeFonts.xiuzhen`                     | 仓耳秀蓁体             |
| `tsangertypeFonts.xiyuan`                      | 仓耳细圆体             |
| `tsangertypeFonts.xuansan01-w01`               | 仓耳玄三01-W01         |
| `tsangertypeFonts.xuansan01-w02`               | 仓耳玄三01-W02         |
| `tsangertypeFonts.xuansan01-w03`               | 仓耳玄三01-W03         |
| `tsangertypeFonts.xuansan01-w04`               | 仓耳玄三01-W04         |
| `tsangertypeFonts.xuansan01-w05`               | 仓耳玄三01-W05         |
| `tsangertypeFonts.xuansan02-w01`               | 仓耳玄三02-W01         |
| `tsangertypeFonts.xuansan02-w02`               | 仓耳玄三02-W02         |
| `tsangertypeFonts.xuansan02-w03`               | 仓耳玄三02-W03         |
| `tsangertypeFonts.xuansan02-w04`               | 仓耳玄三02-W04         |
| `tsangertypeFonts.xuansan02-w05`               | 仓耳玄三02-W05         |
| `tsangertypeFonts.xuansan03-w01`               | 仓耳玄三03-W01         |
| `tsangertypeFonts.xuansan03-w02`               | 仓耳玄三03-W02         |
| `tsangertypeFonts.xuansan03-w03`               | 仓耳玄三03-W03         |
| `tsangertypeFonts.xuansan03-w04`               | 仓耳玄三03-W04         |
| `tsangertypeFonts.xuansan03-w05`               | 仓耳玄三03-W05         |
| `tsangertypeFonts.xuansan04-w01`               | 仓耳玄三04-W01         |
| `tsangertypeFonts.xuansan04-w02`               | 仓耳玄三04-W02         |
| `tsangertypeFonts.xuansan04-w03`               | 仓耳玄三04-W03         |
| `tsangertypeFonts.xuansan04-w04`               | 仓耳玄三04-W04         |
| `tsangertypeFonts.xuansan04-w05`               | 仓耳玄三04-W05         |
| `tsangertypeFonts.xuansanm-w01`                | 仓耳玄三M-W01          |
| `tsangertypeFonts.xuansanm-w02`                | 仓耳玄三M-W02          |
| `tsangertypeFonts.xuansanm-w03`                | 仓耳玄三M-W03          |
| `tsangertypeFonts.xuansanm-w04`                | 仓耳玄三M-W04          |
| `tsangertypeFonts.xuansanm-w05`                | 仓耳玄三M-W05          |
| `tsangertypeFonts.xunmengshilitaohua`          | 寻梦十里桃花体         |
| `tsangertypeFonts.xunzhaomoxianshouxie`        | 寻找魔仙手写体         |
| `tsangertypeFonts.yangguangmingmei`            | 仓耳阳光明媚体         |
| `tsangertypeFonts.yangming`                    | 仓耳阳明体             |
| `tsangertypeFonts.yaoguangxingshu`             | 仓耳尧光行书           |
| `tsangertypeFonts.yasong`                      | 仓耳雅宋               |
| `tsangertypeFonts.yayue`                       | 仓耳雅月体             |
| `tsangertypeFonts.yezhiling`                   | 仓耳叶之灵体           |
| `tsangertypeFonts.yihei-w01`                   | 仓耳逸黑W01            |
| `tsangertypeFonts.yihei-w02`                   | 仓耳逸黑W02            |
| `tsangertypeFonts.yihei-w03`                   | 仓耳逸黑W03            |
| `tsangertypeFonts.yihei-w04`                   | 仓耳逸黑W04            |
| `tsangertypeFonts.yihei-w05`                   | 仓耳逸黑W05            |
| `tsangertypeFonts.yinghe`                      | 仓耳硬核体             |
| `tsangertypeFonts.yiranyizha`                  | 仓耳易燃易炸体         |
| `tsangertypeFonts.yishibuding`                 | 仓耳意式布丁体         |
| `tsangertypeFonts.yisong`                      | 仓耳宜宋               |
| `tsangertypeFonts.yiyechunfeng`                | 仓耳一夜春风体         |
| `tsangertypeFonts.youran`                      | 仓耳悠然体             |
| `tsangertypeFonts.yuanbao`                     | 仓耳元宝体             |
| `tsangertypeFonts.yucheng-w01`                 | 仓耳羽辰体W01          |
| `tsangertypeFonts.yucheng-w02`                 | 仓耳羽辰体W02          |
| `tsangertypeFonts.yucheng-w03`                 | 仓耳羽辰体W03          |
| `tsangertypeFonts.yucheng-w04`                 | 仓耳羽辰体W04          |
| `tsangertypeFonts.yucheng-w05`                 | 仓耳羽辰体W05          |
| `tsangertypeFonts.yudong`                      | 仓耳悦动体             |
| `tsangertypeFonts.yueman`                      | 仓耳月满体             |
| `tsangertypeFonts.yukai`                       | 仓耳玉楷               |
| `tsangertypeFonts.yule`                        | 仓耳鱼乐体             |
| `tsangertypeFonts.yunhaisongtao`               | 仓耳云海松涛体         |
| `tsangertypeFonts.yunhei-w01`                  | 仓耳云黑-W01           |
| `tsangertypeFonts.yunhei-w02`                  | 仓耳云黑-W02           |
| `tsangertypeFonts.yunhei-w03`                  | 仓耳云黑-W03           |
| `tsangertypeFonts.yunhei-w04`                  | 仓耳云黑-W04           |
| `tsangertypeFonts.yunhei-w05`                  | 仓耳云黑-W05           |
| `tsangertypeFonts.yunhei-w06`                  | 仓耳云黑-W06           |
| `tsangertypeFonts.yunhei-w07`                  | 仓耳云黑-W07           |
| `tsangertypeFonts.yunhei-w08`                  | 仓耳云黑-W08           |
| `tsangertypeFonts.yunxuan`                     | 仓耳云轩体             |
| `tsangertypeFonts.yuxiaoxiao`                  | 仓耳雨潇潇体           |
| `tsangertypeFonts.zaijiannaxienian`            | 仓耳再见那些年体       |
| `tsangertypeFonts.zengguofan`                  | 仓耳曾国藩体           |
| `tsangertypeFonts.zhangyuxiaowanzi`            | 仓耳章鱼小丸子体       |
| `tsangertypeFonts.zhenzhu`                     | 仓耳珍珠体             |
| `tsangertypeFonts.zhiqu-w01`                   | 仓耳知曲体W01          |
| `tsangertypeFonts.zhiqu-w02`                   | 仓耳知曲体W02          |
| `tsangertypeFonts.zhiqu-w03`                   | 仓耳知曲体W03          |
| `tsangertypeFonts.zhiqu-w04`                   | 仓耳知曲体W04          |
| `tsangertypeFonts.zhiqu-w05`                   | 仓耳知曲体W05          |
| `tsangertypeFonts.zhixiangkanzheni`            | 仓耳只想看着你         |
| `tsangertypeFonts.zhixin`                      | 仓耳知新体             |
| `tsangertypeFonts.zhiyuxiwenqing`              | 仓耳治愈系文青         |
| `tsangertypeFonts.zhouxinyoulong`              | 仓耳周鑫游龙体         |
| `tsangertypeFonts.zhuangyuankai`               | 仓耳状元楷             |
| `tsangertypeFonts.zhuyan`                      | 仓耳竹言体             |
| `tsangertypeFonts.zongheng`                    | 仓耳纵横体             |

#### 缺失的字体

- [仓耳元气满满的青春体], 上游缺失；

[仓耳元气满满的青春体]: http://tsanger.cn/product/251

## 协议

除非特殊说明，你可以在 __Do What The Fuck You Want To Public License, Version 2__ 条款内做任何事。伴随源代码，你应当已收到了该协议的副本，如果没有，请访问 <http://www.wtfpl.net> 查看该协议的描述。

[^1]: http://tsanger.cn/仓耳字库免费商用字体授权声明.pdf
[^2]: https://www.foundertype.com/index.php/About/powerbus.html
[^3]: https://www.foundertype.com/index.php/About/powerPer.html
[^4]: http://cheonhyeong.com/Simplified/download.html
