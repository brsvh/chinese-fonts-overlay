# tsangertype fonts

[![brsvh](https://img.shields.io/badge/cachix-brsvh-blue.svg)](https://brsvh.cachix.org)

这个仓库用于提供仓耳字库的所有字体。

## 简介

这个仓库的 flake 提供了三个 overlay：

> [!WARNING]
> 此处的 free 与 unfree 是指关于是否允许商用（价格），而不是自由与非自由的区别。

- free: 包括仓耳字库免费商业授权声明的 22 款免费字体。
- unfree: 除仓耳字库免费商业授权声明的 22 款免费字体外剩余所有允许个人非商业使用的所有字体。
- default: 仓耳字库的所有字体，即上面两者的合集。

> [!NOTE]
> 仓耳字库免费商用字体授权声明[^1]中使用了“免费开源字体”等字样，但我未找到其源代码。

## 开始上手

你只需要将此仓库的 overlay 添加至你的配置中然后安装期望的字体即可。


``` nix
{
  nixConfig = {
    extra-substituters =
      [
        "https://brsvh.cachix.org"
      ];

    extra-trusted-public-keys =
      [
        "brsvh.cachix.org-1:DqtlvqnpP9g39l8Eo74AXRftGx1KJLid/ViADTNgDNE="
      ];
  };
  
  inputs = {
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tsangertype-fonts.url = "github:brsvh/tsangertype-fonts-overlays/main";
  };

  output = { home-manager, nixpkgs, tsangertype-fonts, ... } @ inputs: {
    homeConfigurations.YOUR-CONFIGURATION-NAME =
      home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        modules = [
          { pkgs
          , ...
          }:
          {
            nixpkgs = {
              config = {
                allowUnfree = true;
              };

              overlays =
                [
                  tsangertype-fonts.overlays.default # 所有字体
                  # tsangertype-fonts.overlays.free    # 免费商用字体
                  # tsangertype-fonts.overlays.unfree  # 个人非商用字体
                ];
            };
            
            home = {
              packages = with pkgs;
                [
                  tsangertype-free-fonts          # 所有免费商用字体
                  # tsangertype-unfree-fonts      # 所有个人非商用字体
                  # tsangertype-fonts             # 所有字体
                  # tsangertype-font-jinkai01-w01 # 仓耳今楷01-W01
                  # ...
                ];
            };
          }
        ];
      };
      
    nixosConfigurations.YOUR-CONFIGURATOIN-NAME =
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { pkgs
          , ...
          }:
          {
            nixpkgs = {
              config = {
                allowUnfree = true;
              };

              overlays =
                [
                  tsangertype-fonts.overlays.default # 所有字体
                  # tsangertype-fonts.overlays.free    # 免费商用字体
                  # tsangertype-fonts.overlays.unfree  # 个人非商用字体
                ];
            };
            
            environment = {
              systemPackages = with pkgs;
                [
                  tsangertype-free-fonts          # 所有免费商用字体
                  # tsangertype-unfree-fonts      # 所有个人非商用字体
                  # tsangertype-fonts             # 所有字体
                  # tsangertype-font-jinkai01-w01 # 仓耳今楷01-W01
                  # ...
                ];
            };
          }
        ];
      };
  };
}
```

## 构建

构建所有字体到本地 store:

``` shell
nix build .#tsangertype-fonts
```


更新 shas.nix 中的校验值：

``` nix
./update.sh
```

## 协议

除非特殊说明，你可以在 __Do What The Fuck You Want To Public License, Version 2__ 条款内做任何事。伴随源代码，你应当已收到了该协议的副本，如果没有，请访问 <http://www.wtfpl.net> 查看该协议的描述。

## 提供的字体

`tsangertype-fonts` 是所有字体的链接。

### 免费商用

`tsangertype-free-fonts` 是所有免费商用字体的链接。

| 包                                      | 字体             |
|-----------------------------------------|------------------|
| `tsangertype-font-feibai-w01`           | 仓耳非白W01      |
| `tsangertype-font-feibai-w02`           | 仓耳非白W02      |
| `tsangertype-font-feibai-w03`           | 仓耳非白W03      |
| `tsangertype-font-feibai-w04`           | 仓耳非白W04      |
| `tsangertype-font-feibai-w05`           | 仓耳非白W05      |
| `tsangertype-font-shuyuan-w01`          | 仓耳舒圆体W01    |
| `tsangertype-font-shuyuan-w02`          | 仓耳舒圆体W02    |
| `tsangertype-font-shuyuan-w03`          | 仓耳舒圆体W03    |
| `tsangertype-font-shuyuan-w04`          | 仓耳舒圆体W04    |
| `tsangertype-font-shuyuan-w05`          | 仓耳舒圆体W05    |
| `tsangertype-font-xiaowanzi`            | 仓耳小丸子       |
| `tsangertype-font-yumo-w01`             | 仓耳与墨W01      |
| `tsangertype-font-yumo-w02`             | 仓耳与墨W02      |
| `tsangertype-font-yumo-w03`             | 仓耳与墨W03      |
| `tsangertype-font-yumo-w04`             | 仓耳与墨W04      |
| `tsangertype-font-yumo-w05`             | 仓耳与墨W05      |
| `tsangertype-font-yuyang-w01`           | 仓耳渔阳体W01    |
| `tsangertype-font-yuyang-w02`           | 仓耳渔阳体W02    |
| `tsangertype-font-yuyang-w03`           | 仓耳渔阳体W03    |
| `tsangertype-font-yuyang-w04`           | 仓耳渔阳体W04    |
| `tsangertype-font-yuyang-w05`           | 仓耳渔阳体W05    |
| `tsangertype-font-zhoukezhengdabangshu` | 仓耳周珂正大榜书 |

### 个人非商用

`tsangertype-unfree-fonts` 是所有个人非商用字体的链接。

| 包                                             | 字体                   |
|------------------------------------------------|------------------------|
| `tsangertype-font-aidekunkun`                  | 仓耳爱的坤坤体         |
| `tsangertype-font-aiminxiaokai`                | 仓耳爱民小楷           |
| `tsangertype-font-aiminxingkai`                | 仓耳爱民行楷           |
| `tsangertype-font-aiminxingshu`                | 仓耳爱民行书           |
| `tsangertype-font-ainimengmengda`              | 仓耳爱你萌萌哒         |
| `tsangertype-font-aiqinglianxisheng`           | 仓耳爱情练习生         |
| `tsangertype-font-babilong`                    | 仓耳吧吡咙体           |
| `tsangertype-font-bailing-w01`                 | 仓耳百灵W01            |
| `tsangertype-font-bailing-w02`                 | 仓耳百灵W02            |
| `tsangertype-font-bailing-w03`                 | 仓耳百灵W03            |
| `tsangertype-font-bailing-w04`                 | 仓耳百灵W04            |
| `tsangertype-font-bailing-w05`                 | 仓耳百灵W05            |
| `tsangertype-font-banghei`                     | 仓耳榜黑               |
| `tsangertype-font-bantangshouzha`              | 仓耳半糖手札           |
| `tsangertype-font-benmiaozaici`                | 仓耳本喵在此体         |
| `tsangertype-font-cangermuxi`                  | 仓耳木兮体             |
| `tsangertype-font-caolulinshouji`              | 仓耳曹录林手迹         |
| `tsangertype-font-caozhebinjunxiukaishu`       | 仓耳曹哲斌俊秀楷书     |
| `tsangertype-font-caozhebinjunxiukaishu-bold`  | 仓耳曹哲斌俊秀楷书加粗 |
| `tsangertype-font-caozhebinkaishu`             | 仓耳曹哲斌楷书         |
| `tsangertype-font-caozhebinkaishu-bold`        | 仓耳曹哲斌楷书加粗     |
| `tsangertype-font-caozhebinlingyunkaishu`      | 仓耳曹哲斌灵韵楷书     |
| `tsangertype-font-caozhebinlingyunkaishu-bold` | 仓耳曹哲斌灵韵楷书加粗 |
| `tsangertype-font-caozhebinxingkai`            | 仓耳曹哲斌行楷         |
| `tsangertype-font-chengshishangkongdefanxing`  | 城市上空的繁星体       |
| `tsangertype-font-chuangyi-w01`                | 仓耳创意体W01          |
| `tsangertype-font-chuangyi-w02`                | 仓耳创意体W02          |
| `tsangertype-font-chuangyi-w03`                | 仓耳创意体W03          |
| `tsangertype-font-chunfeng`                    | 仓耳春风体             |
| `tsangertype-font-chuyu`                       | 仓耳初遇体             |
| `tsangertype-font-daimengxiaomutou`            | 仓耳呆萌小木头体       |
| `tsangertype-font-dainiushouxie`               | 呆牛手写体             |
| `tsangertype-font-daji`                        | 仓耳大吉体             |
| `tsangertype-font-damanman-w01`                | 仓耳大漫漫体W01        |
| `tsangertype-font-damanman-w02`                | 仓耳大漫漫体W02        |
| `tsangertype-font-damanman-w03`                | 仓耳大漫漫体W03        |
| `tsangertype-font-damanman-w04`                | 仓耳大漫漫体W04        |
| `tsangertype-font-damanman-w05`                | 仓耳大漫漫体W05        |
| `tsangertype-font-daofengzhanshi`              | 刀锋战士体             |
| `tsangertype-font-daofengzhanshi-bold`         | 刀锋战士粗体           |
| `tsangertype-font-dianshichengjin`             | 仓耳点石成金体         |
| `tsangertype-font-diewu`                       | 仓耳蝶舞体             |
| `tsangertype-font-diyiyanaishangni`            | 仓耳第一眼爱上你       |
| `tsangertype-font-dubai`                       | 仓耳独白体             |
| `tsangertype-font-dudu-w01`                    | 仓耳嘟嘟体W01          |
| `tsangertype-font-dudu-w02`                    | 仓耳嘟嘟体W02          |
| `tsangertype-font-dudu-w03`                    | 仓耳嘟嘟体W03          |
| `tsangertype-font-dudu-w04`                    | 仓耳嘟嘟体W04          |
| `tsangertype-font-fanghei`                     | 仓耳方黑               |
| `tsangertype-font-feifei-w01`                  | 仓耳飞飞体W01          |
| `tsangertype-font-feifei-w02`                  | 仓耳飞飞体W02          |
| `tsangertype-font-feifei-w03`                  | 仓耳飞飞体W03          |
| `tsangertype-font-feifei-w04`                  | 仓耳飞飞体W04          |
| `tsangertype-font-feiteng`                     | 仓耳沸腾体             |
| `tsangertype-font-fengerchui`                  | 仓耳风儿吹             |
| `tsangertype-font-fenghei`                     | 仓耳丰黑               |
| `tsangertype-font-fengwujiutian-w01`           | 仓耳锋舞九天W01        |
| `tsangertype-font-fengwujiutian-w02`           | 仓耳锋舞九天W02        |
| `tsangertype-font-fengwujiutian-w03`           | 仓耳锋舞九天W03        |
| `tsangertype-font-fengwujiutian-w04`           | 仓耳锋舞九天W04        |
| `tsangertype-font-fengwujiutian-w05`           | 仓耳锋舞九天W05        |
| `tsangertype-font-fengwujiutian-w06`           | 仓耳锋舞九天W06        |
| `tsangertype-font-fengyun-w01`                 | 仓耳锋韵W01            |
| `tsangertype-font-fengyun-w02`                 | 仓耳锋韵W02            |
| `tsangertype-font-fengyun-w03`                 | 仓耳锋韵W03            |
| `tsangertype-font-fengyun-w04`                 | 仓耳锋韵W04            |
| `tsangertype-font-fengyun-w05`                 | 仓耳锋韵W05            |
| `tsangertype-font-fengyun-w06`                 | 仓耳锋韵W06            |
| `tsangertype-font-fengyun-w07`                 | 仓耳锋韵W07            |
| `tsangertype-font-gexingtuya`                  | 仓耳个性涂鸦体         |
| `tsangertype-font-guateng`                     | 仓耳瓜藤体             |
| `tsangertype-font-gufengkaishu`                | 仓耳古风楷书           |
| `tsangertype-font-gufengxingshu`               | 仓耳古风行书           |
| `tsangertype-font-guli-w01`                    | 仓耳谷力W01            |
| `tsangertype-font-guli-w02`                    | 仓耳谷力W02            |
| `tsangertype-font-guli-w03`                    | 仓耳谷力W03            |
| `tsangertype-font-guli-w04`                    | 仓耳谷力W04            |
| `tsangertype-font-guli-w05`                    | 仓耳谷力W05            |
| `tsangertype-font-guodongxixi`                 | 仓耳果冻吸吸体         |
| `tsangertype-font-guyun`                       | 仓耳古韵体             |
| `tsangertype-font-haloutuxiansheng`            | 仓耳哈喽兔先生体       |
| `tsangertype-font-hanshan`                     | 仓耳寒山体             |
| `tsangertype-font-hefeng`                      | 仓耳荷风体             |
| `tsangertype-font-huayu`                       | 仓耳花语               |
| `tsangertype-font-jiaotangmaqiduo`             | 仓耳焦糖玛奇朵体       |
| `tsangertype-font-jiaxuan`                     | 仓耳佳轩体             |
| `tsangertype-font-jiekou`                      | 仓耳结扣体             |
| `tsangertype-font-jiemo`                       | 仓耳芥末体             |
| `tsangertype-font-jingya`                      | 仓耳静雅体             |
| `tsangertype-font-jinkai01-w01`                | 仓耳今楷01-W01         |
| `tsangertype-font-jinkai01-w02`                | 仓耳今楷01-W02         |
| `tsangertype-font-jinkai01-w03`                | 仓耳今楷01-W03         |
| `tsangertype-font-jinkai01-w04`                | 仓耳今楷01-W04         |
| `tsangertype-font-jinkai01-w05`                | 仓耳今楷01-W05         |
| `tsangertype-font-jinkai02-w01`                | 仓耳今楷02-W01         |
| `tsangertype-font-jinkai02-w02`                | 仓耳今楷02-W02         |
| `tsangertype-font-jinkai02-w03`                | 仓耳今楷02-W03         |
| `tsangertype-font-jinkai02-w04`                | 仓耳今楷02-W04         |
| `tsangertype-font-jinkai02-w05`                | 仓耳今楷02-W05         |
| `tsangertype-font-jinkai03-w01`                | 仓耳今楷03-W01         |
| `tsangertype-font-jinkai03-w02`                | 仓耳今楷03-W02         |
| `tsangertype-font-jinkai03-w03`                | 仓耳今楷03-W03         |
| `tsangertype-font-jinkai03-w04`                | 仓耳今楷03-W04         |
| `tsangertype-font-jinkai03-w05`                | 仓耳今楷03-W05         |
| `tsangertype-font-jinkai04-w01`                | 仓耳今楷04-W01         |
| `tsangertype-font-jinkai04-w02`                | 仓耳今楷04-W02         |
| `tsangertype-font-jinkai04-w03`                | 仓耳今楷04-W03         |
| `tsangertype-font-jinkai04-w04`                | 仓耳今楷04-W04         |
| `tsangertype-font-jinkai04-w05`                | 仓耳今楷04-W05         |
| `tsangertype-font-jinkai05-w01`                | 仓耳今楷05-W01         |
| `tsangertype-font-jinkai05-w02`                | 仓耳今楷05-W02         |
| `tsangertype-font-jinkai05-w03`                | 仓耳今楷05-W03         |
| `tsangertype-font-jinkai05-w04`                | 仓耳今楷05-W04         |
| `tsangertype-font-jinkai05-w05`                | 仓耳今楷05-W05         |
| `tsangertype-font-jinshirongyao`               | 仓耳金石荣耀体         |
| `tsangertype-font-jundongkaishu`               | 仓耳俊冬楷书           |
| `tsangertype-font-jundongxingshu`              | 仓耳俊冬行书           |
| `tsangertype-font-juziwei`                     | 仓耳橘子味             |
| `tsangertype-font-keke`                        | 仓耳柯柯体             |
| `tsangertype-font-konglukaishu`                | 仓耳孔璐楷书           |
| `tsangertype-font-lankai`                      | 仓耳兰楷               |
| `tsangertype-font-leizhenhanfeng`              | 仓耳雷震汉风体         |
| `tsangertype-font-lekeke`                      | 仓耳乐可可体           |
| `tsangertype-font-lelebiji`                    | 乐乐笔记体             |
| `tsangertype-font-lezhi`                       | 仓耳乐志体             |
| `tsangertype-font-lianaibiji`                  | 仓耳恋爱笔记体         |
| `tsangertype-font-lifei`                       | 仓耳利飞体             |
| `tsangertype-font-linggang-w01`                | 仓耳凌刚体W01          |
| `tsangertype-font-linggang-w02`                | 仓耳凌刚体W02          |
| `tsangertype-font-linggang-w03`                | 仓耳凌刚体W03          |
| `tsangertype-font-linggang-w04`                | 仓耳凌刚体W04          |
| `tsangertype-font-linggang-w05`                | 仓耳凌刚体W05          |
| `tsangertype-font-lingyun`                     | 仓耳凌云体             |
| `tsangertype-font-lishi`                       | 仓耳力士体             |
| `tsangertype-font-liyuan`                      | 仓耳丽圆               |
| `tsangertype-font-manmiao`                     | 仓耳曼妙体             |
| `tsangertype-font-maobohe`                     | 仓耳猫薄荷体           |
| `tsangertype-font-meixin-w01`                  | 仓耳美心体W01          |
| `tsangertype-font-meixin-w02`                  | 仓耳美心体W02          |
| `tsangertype-font-mengbaokeji`                 | 仓耳萌宝柯基体         |
| `tsangertype-font-mengdaimiaowei`              | 仓耳萌呆喵尾体         |
| `tsangertype-font-mengdie`                     | 仓耳梦蝶体             |
| `tsangertype-font-mengduoduo`                  | 仓耳萌朵朵体           |
| `tsangertype-font-mengmengdaxiaodouzi`         | 萌萌哒小豆子体         |
| `tsangertype-font-mengmiaojiang`               | 仓耳萌喵酱             |
| `tsangertype-font-mengtonglishu`               | 仓耳梦桐隶书           |
| `tsangertype-font-mengxingdelibie`             | 仓耳梦醒的离别体       |
| `tsangertype-font-minghei-w01`                 | 仓耳明黑W01            |
| `tsangertype-font-minghei-w02`                 | 仓耳明黑W02            |
| `tsangertype-font-minghei-w03`                 | 仓耳明黑W03            |
| `tsangertype-font-minghei-w04`                 | 仓耳明黑W04            |
| `tsangertype-font-minghei-w05`                 | 仓耳明黑W05            |
| `tsangertype-font-minghei-w06`                 | 仓耳明黑W06            |
| `tsangertype-font-minghei-w07`                 | 仓耳明黑W07            |
| `tsangertype-font-minghei-w08`                 | 仓耳明黑W08            |
| `tsangertype-font-mingkai-w01`                 | 仓耳明楷W01            |
| `tsangertype-font-mingkai-w02`                 | 仓耳明楷W02            |
| `tsangertype-font-mingkai-w03`                 | 仓耳明楷W03            |
| `tsangertype-font-mingkai-w04`                 | 仓耳明楷W04            |
| `tsangertype-font-mingyue`                     | 仓耳明月体             |
| `tsangertype-font-mizhiguo`                    | 仓耳秘之果             |
| `tsangertype-font-mocha`                       | 仓耳抹茶体             |
| `tsangertype-font-nihaoshiguang`               | 仓耳你好时光体         |
| `tsangertype-font-nishiwodequanshijie`         | 你是我的全世界         |
| `tsangertype-font-nishiwoweiyi`                | 仓耳你是我唯一         |
| `tsangertype-font-nuannanshouzha`              | 仓耳暖男手札体         |
| `tsangertype-font-nuanxin`                     | 仓耳暖心体             |
| `tsangertype-font-nvwang`                      | 仓耳女王体             |
| `tsangertype-font-peiban`                      | 仓耳陪伴体             |
| `tsangertype-font-piaomiao`                    | 仓耳缥缈体             |
| `tsangertype-font-qiaole-w01`                  | 仓耳巧乐W01            |
| `tsangertype-font-qiaole-w02`                  | 仓耳巧乐W02            |
| `tsangertype-font-qiaole-w03`                  | 仓耳巧乐W03            |
| `tsangertype-font-qiaole-w04`                  | 仓耳巧乐W04            |
| `tsangertype-font-qiaole-w05`                  | 仓耳巧乐W05            |
| `tsangertype-font-qiedoudou`                   | 仓耳企鹅豆豆体         |
| `tsangertype-font-qiming`                      | 仓耳启明体             |
| `tsangertype-font-qingchunyiniweiming`         | 仓耳青春以你为名体     |
| `tsangertype-font-qingfeng`                    | 仓耳清风体             |
| `tsangertype-font-qingfengxieyang`             | 仓耳轻风斜阳体         |
| `tsangertype-font-qinghe-w01`                  | 仓耳青禾体W01          |
| `tsangertype-font-qinghe-w02`                  | 仓耳青禾体W02          |
| `tsangertype-font-qinghe-w03`                  | 仓耳青禾体W03          |
| `tsangertype-font-qinghe-w04`                  | 仓耳青禾体W04          |
| `tsangertype-font-qinghe-w05`                  | 仓耳青禾体W05          |
| `tsangertype-font-qinghuan`                    | 仓耳清欢体             |
| `tsangertype-font-qingji`                      | 仓耳青吉体             |
| `tsangertype-font-qingmei`                     | 仓耳青梅体             |
| `tsangertype-font-qingning`                    | 仓耳青柠体             |
| `tsangertype-font-qingqiuxiaojiu`              | 仓耳青丘小九           |
| `tsangertype-font-qingque`                     | 仓耳青雀体             |
| `tsangertype-font-qingsong`                    | 仓耳青宋               |
| `tsangertype-font-qingxin`                     | 仓耳晴心体             |
| `tsangertype-font-qingyou`                     | 仓耳轻悠体             |
| `tsangertype-font-qinqinmeizhuang`             | 亲亲美妆体             |
| `tsangertype-font-qiuyue`                      | 仓耳秋月体             |
| `tsangertype-font-quancunzuikeai`              | 仓耳全村最可爱         |
| `tsangertype-font-quhei`                       | 仓耳趣黑               |
| `tsangertype-font-rouhei`                      | 仓耳柔黑               |
| `tsangertype-font-ruihei`                      | 仓耳锐黑               |
| `tsangertype-font-runhei-w01`                  | 仓耳润黑W01            |
| `tsangertype-font-runhei-w02`                  | 仓耳润黑W02            |
| `tsangertype-font-runhei-w03`                  | 仓耳润黑W03            |
| `tsangertype-font-shangshanruoshui`            | 仓耳上善若水           |
| `tsangertype-font-shenniaoxinshengchuangyi`    | 神鸟新生创意体         |
| `tsangertype-font-shenqidedoudou`              | 仓耳神奇的豆豆体       |
| `tsangertype-font-sirou`                       | 仓耳丝柔体             |
| `tsangertype-font-siyaoxingkai`                | 仓耳丝摇行楷           |
| `tsangertype-font-siyecaodexingfu`             | 仓耳四叶草的幸福体     |
| `tsangertype-font-songguo`                     | 松果体                 |
| `tsangertype-font-suxin`                       | 仓耳苏心体             |
| `tsangertype-font-tianmimi`                    | 仓耳甜蜜蜜体           |
| `tsangertype-font-tianmu-w01`                  | 仓耳天沐体W01          |
| `tsangertype-font-tianmu-w02`                  | 仓耳天沐体W02          |
| `tsangertype-font-tianmu-w03`                  | 仓耳天沐体W03          |
| `tsangertype-font-tianmu-w04`                  | 仓耳天沐体W04          |
| `tsangertype-font-tianmu-w05`                  | 仓耳天沐体W05          |
| `tsangertype-font-tianqunxingkai`              | 仓耳天群行楷           |
| `tsangertype-font-tiansuolele`                 | 仓耳天锁乐乐体         |
| `tsangertype-font-tingfeng`                    | 仓耳听风体             |
| `tsangertype-font-tongzhuo`                    | 仓耳同桌体             |
| `tsangertype-font-tuya-w01`                    | 仓耳涂鸦体W01          |
| `tsangertype-font-tuya-w02`                    | 仓耳涂鸦体W02          |
| `tsangertype-font-tuya-w03`                    | 仓耳涂鸦体W03          |
| `tsangertype-font-wandongxingshu`              | 仓耳万东行书           |
| `tsangertype-font-weilairiji`                  | 未来日记体             |
| `tsangertype-font-wugexingbuqingchun`          | 仓耳无个性不青春体     |
| `tsangertype-font-wuliangshoufu`               | 仓耳无量寿福体         |
| `tsangertype-font-xiangzuozouxiangyouzou`      | 仓耳向左走向右走体     |
| `tsangertype-font-xiaobaikaishu`               | 仓耳小白楷书           |
| `tsangertype-font-xiaobaiwan`                  | 仓耳小百万             |
| `tsangertype-font-xiaobaixingshu`              | 仓耳小白行书           |
| `tsangertype-font-xiaodianer`                  | 仓耳小点儿体           |
| `tsangertype-font-xiaofang`                    | 仓耳小方体             |
| `tsangertype-font-xiaokeai-w01`                | 仓耳小可爱体W01        |
| `tsangertype-font-xiaokeai-w02`                | 仓耳小可爱体W02        |
| `tsangertype-font-xiaokeai-w03`                | 仓耳小可爱体W03        |
| `tsangertype-font-xiaokeai-w04`                | 仓耳小可爱体W04        |
| `tsangertype-font-xiaokeai-w05`                | 仓耳小可爱体W05        |
| `tsangertype-font-xiaokeai-w06`                | 仓耳小可爱体W06        |
| `tsangertype-font-xiaomanman-w01`              | 仓耳小漫漫体W01        |
| `tsangertype-font-xiaomanman-w02`              | 仓耳小漫漫体W02        |
| `tsangertype-font-xiaomanman-w03`              | 仓耳小漫漫体W03        |
| `tsangertype-font-xiaomanman-w04`              | 仓耳小漫漫体W04        |
| `tsangertype-font-xiaomanman-w05`              | 仓耳小漫漫体W05        |
| `tsangertype-font-feigexiaosaxingshu`          | 飞哥潇洒行书           |
| `tsangertype-font-xiaoshipin`                  | 仓耳小视频体           |
| `tsangertype-font-xiaowoniudemeng`             | 仓耳小蜗牛的梦         |
| `tsangertype-font-xiaoxiaohuochai`             | 仓耳小小火柴体         |
| `tsangertype-font-xiaoxiaomangguo`             | 仓耳小小芒果体         |
| `tsangertype-font-xiaoyaoxingshu`              | 仓耳逍遥行书           |
| `tsangertype-font-xiaoyashouji`                | 仓耳小雅手迹           |
| `tsangertype-font-xiaoyutongxue`               | 仓耳小雨同学体         |
| `tsangertype-font-xiayizhanxingfu`             | 仓耳下一站幸福体       |
| `tsangertype-font-xingchenkaishu`              | 仓耳星辰楷书           |
| `tsangertype-font-xingfuyuezhang`              | 仓耳幸福乐章体         |
| `tsangertype-font-xinghansong`                 | 仓耳星汉宋             |
| `tsangertype-font-xinxing`                     | 仓耳心星体             |
| `tsangertype-font-xinyan`                      | 仓耳新颜体             |
| `tsangertype-font-xinyue01`                    | 仓耳新悦体             |
| `tsangertype-font-xinyue02`                    | 仓耳欣月体             |
| `tsangertype-font-xiuxianxingshu`              | 仓耳绣线行书           |
| `tsangertype-font-xiuzhen`                     | 仓耳秀蓁体             |
| `tsangertype-font-xiyuan`                      | 仓耳细圆体             |
| `tsangertype-font-xuansan01-w01`               | 仓耳玄三01-W01         |
| `tsangertype-font-xuansan01-w02`               | 仓耳玄三01-W02         |
| `tsangertype-font-xuansan01-w03`               | 仓耳玄三01-W03         |
| `tsangertype-font-xuansan01-w04`               | 仓耳玄三01-W04         |
| `tsangertype-font-xuansan01-w05`               | 仓耳玄三01-W05         |
| `tsangertype-font-xuansan02-w01`               | 仓耳玄三02-W01         |
| `tsangertype-font-xuansan02-w02`               | 仓耳玄三02-W02         |
| `tsangertype-font-xuansan02-w03`               | 仓耳玄三02-W03         |
| `tsangertype-font-xuansan02-w04`               | 仓耳玄三02-W04         |
| `tsangertype-font-xuansan02-w05`               | 仓耳玄三02-W05         |
| `tsangertype-font-xuansan03-w01`               | 仓耳玄三03-W01         |
| `tsangertype-font-xuansan03-w02`               | 仓耳玄三03-W02         |
| `tsangertype-font-xuansan03-w03`               | 仓耳玄三03-W03         |
| `tsangertype-font-xuansan03-w04`               | 仓耳玄三03-W04         |
| `tsangertype-font-xuansan03-w05`               | 仓耳玄三03-W05         |
| `tsangertype-font-xuansan04-w01`               | 仓耳玄三04-W01         |
| `tsangertype-font-xuansan04-w02`               | 仓耳玄三04-W02         |
| `tsangertype-font-xuansan04-w03`               | 仓耳玄三04-W03         |
| `tsangertype-font-xuansan04-w04`               | 仓耳玄三04-W04         |
| `tsangertype-font-xuansan04-w05`               | 仓耳玄三04-W05         |
| `tsangertype-font-xuansanm-w01`                | 仓耳玄三M-W01          |
| `tsangertype-font-xuansanm-w02`                | 仓耳玄三M-W02          |
| `tsangertype-font-xuansanm-w03`                | 仓耳玄三M-W03          |
| `tsangertype-font-xuansanm-w04`                | 仓耳玄三M-W04          |
| `tsangertype-font-xuansanm-w05`                | 仓耳玄三M-W05          |
| `tsangertype-font-xunmengshilitaohua`          | 寻梦十里桃花体         |
| `tsangertype-font-xunzhaomoxianshouxie`        | 寻找魔仙手写体         |
| `tsangertype-font-yangguangmingmei`            | 仓耳阳光明媚体         |
| `tsangertype-font-yangming`                    | 仓耳阳明体             |
| `tsangertype-font-yaoguangxingshu`             | 仓耳尧光行书           |
| `tsangertype-font-yasong`                      | 仓耳雅宋               |
| `tsangertype-font-yayue`                       | 仓耳雅月体             |
| `tsangertype-font-yezhiling`                   | 仓耳叶之灵体           |
| `tsangertype-font-yihei-w01`                   | 仓耳逸黑W01            |
| `tsangertype-font-yihei-w02`                   | 仓耳逸黑W02            |
| `tsangertype-font-yihei-w03`                   | 仓耳逸黑W03            |
| `tsangertype-font-yihei-w04`                   | 仓耳逸黑W04            |
| `tsangertype-font-yihei-w05`                   | 仓耳逸黑W05            |
| `tsangertype-font-yinghe`                      | 仓耳硬核体             |
| `tsangertype-font-yiranyizha`                  | 仓耳易燃易炸体         |
| `tsangertype-font-yishibuding`                 | 仓耳意式布丁体         |
| `tsangertype-font-yisong`                      | 仓耳宜宋               |
| `tsangertype-font-yiyechunfeng`                | 仓耳一夜春风体         |
| `tsangertype-font-youran`                      | 仓耳悠然体             |
| `tsangertype-font-yuanbao`                     | 仓耳元宝体             |
| `tsangertype-font-yucheng-w01`                 | 仓耳羽辰体W01          |
| `tsangertype-font-yucheng-w02`                 | 仓耳羽辰体W02          |
| `tsangertype-font-yucheng-w03`                 | 仓耳羽辰体W03          |
| `tsangertype-font-yucheng-w04`                 | 仓耳羽辰体W04          |
| `tsangertype-font-yucheng-w05`                 | 仓耳羽辰体W05          |
| `tsangertype-font-yudong`                      | 仓耳悦动体             |
| `tsangertype-font-yueman`                      | 仓耳月满体             |
| `tsangertype-font-yukai`                       | 仓耳玉楷               |
| `tsangertype-font-yule`                        | 仓耳鱼乐体             |
| `tsangertype-font-yunhaisongtao`               | 仓耳云海松涛体         |
| `tsangertype-font-yunhei-w01`                  | 仓耳云黑-W01           |
| `tsangertype-font-yunhei-w02`                  | 仓耳云黑-W02           |
| `tsangertype-font-yunhei-w03`                  | 仓耳云黑-W03           |
| `tsangertype-font-yunhei-w04`                  | 仓耳云黑-W04           |
| `tsangertype-font-yunhei-w05`                  | 仓耳云黑-W05           |
| `tsangertype-font-yunhei-w06`                  | 仓耳云黑-W06           |
| `tsangertype-font-yunhei-w07`                  | 仓耳云黑-W07           |
| `tsangertype-font-yunhei-w08`                  | 仓耳云黑-W08           |
| `tsangertype-font-yunxuan`                     | 仓耳云轩体             |
| `tsangertype-font-yuxiaoxiao`                  | 仓耳雨潇潇体           |
| `tsangertype-font-zaijiannaxienian`            | 仓耳再见那些年体       |
| `tsangertype-font-zengguofan`                  | 仓耳曾国藩体           |
| `tsangertype-font-zhangyuxiaowanzi`            | 仓耳章鱼小丸子体       |
| `tsangertype-font-zhenzhu`                     | 仓耳珍珠体             |
| `tsangertype-font-zhiqu-w01`                   | 仓耳知曲体W01          |
| `tsangertype-font-zhiqu-w02`                   | 仓耳知曲体W02          |
| `tsangertype-font-zhiqu-w03`                   | 仓耳知曲体W03          |
| `tsangertype-font-zhiqu-w04`                   | 仓耳知曲体W04          |
| `tsangertype-font-zhiqu-w05`                   | 仓耳知曲体W05          |
| `tsangertype-font-zhixiangkanzheni`            | 仓耳只想看着你         |
| `tsangertype-font-zhixin`                      | 仓耳知新体             |
| `tsangertype-font-zhiyuxiwenqing`              | 仓耳治愈系文青         |
| `tsangertype-font-zhouxinyoulong`              | 仓耳周鑫游龙体         |
| `tsangertype-font-zhuangyuankai`               | 仓耳状元楷             |
| `tsangertype-font-zhuyan`                      | 仓耳竹言体             |
| `tsangertype-font-zongheng`                    | 仓耳纵横体             |

## 缺失的字体

- [仓耳元气满满的青春体], 上游缺失；

[仓耳元气满满的青春体]: http://tsanger.cn/product/251

[^1]: http://tsanger.cn/仓耳字库免费商用字体授权声明.pdf
