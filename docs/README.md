# Chinese Fonts Overlay

这个仓库提供一些中文字体，以 nix packages 的形式帮助您进行构建。

目前主要提供了以下公司、字库的若干字体产品的构建方式：

- Alibaba Design（Alibaba 字体）
- Alimama 字体（阿里妈妈字体）
- DingTalk 字体（钉钉字体）
- FounderType 字库（方正字库）
- Justfont 字体
- Microsoft 字体（微软字体）
- Taobao 字体（淘宝字体）
- TianHeng 字体（TH/天珩字库）
- TrionesType 字体（璇璣造字）
- TsangerType 字体（仓耳字库）
- ZiHi（社群）字型系列字体（字嗨字型系列字體）

## 开始上手

您只需要将此仓库的 overlay 添加至您的配置中然后安装期望的字体即可。

### 与 NixOS 一起使用

如果您需要 NixOS 配置中添加本仓库支持构建的字体，您需要在配置中启用 overlay 后，将需要的字体加入 `fonts.packages`。

例如：

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chinese-fonts-overlay.url = "github:brsvh/chinese-fonts-overlay/main";
  };

  outputs = { nixpkgs, chinese-fonts-overlay, ... }: {
    nixosConfigurations.YOUR-HOST = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ({ pkgs, ... }: {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [ chinese-fonts-overlay.overlays.default ];
        };
        fonts.packages = with pkgs; [ justfontPackages.huninn ];
      }) ];
    };
  };
}
```

### 与 home-manager 一起使用

如果您使用 Home Manager 为当前用户安装字体，在您的 Home Manager 配置中启用本项目 overlay，然后将字体加入
`home.packages`。

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    chinese-fonts-overlay.url = "github:brsvh/chinese-fonts-overlay/main";
  };

  outputs = { nixpkgs, home-manager, chinese-fonts-overlay, ... }: {
    homeConfigurations.YOUR-HOME = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ chinese-fonts-overlay.overlays.default ];
      };
      modules = [ ({ pkgs, ... }: {
        home.packages = with pkgs; [ justfontPackages.huninn ];
      }) ];
    };
  };
}
```

### 本地构建字体

如果您只是想试构建某个字体包，可以从仓库根目录注入 overlay，然后进行构建。

例如：

```console
$ nix build --expr 'with import <nixpkgs> { overlays = [ (import ./default.nix) ]; }; justfontPackages.huninn'
```

> [!TIP]
>
> 当您构建非自由字体时，您需要额外添加环境变量和 `--impure` 参数，比如
> `NIXPKGS_ALLOW_UNFREE=1 nix build --impure --expr 'with import <nixpkgs> { overlays = [ (import ./default.nix) ]; }; tsangertypePackages.tsangerjinkai'`

## 贡献与开发

如果您想请求添加字体、报告构建失败或提交 PR，请阅读[贡献指南](CONTRIBUTING.md)。

如果您准备直接修改字体包、维护预览图或使用本仓库的开发工具，请阅读[开发文档](development.md)。

## 说明与帮助

### 命名约定

为了区别于大多数情况代表是否是自由软件的 `free` 和 `unfree`，我们不使用它们来作为价格的区别，转而利用一些缩写来表明某个字体的收费情况。

- `gpu`代表 _gratis personal use_，表明您可以为个人免费获取字体使用许可。
- `gcu`代表 _gratis commercial use_，表明您可以为商业用途免费获取字体使用许可。
- `paid` 代表 _paid license_，表明您需要付费购买字体的使用许可。

上述命名约定不表明所有使用场景的费用是一致的，您可能面对不同使用场景有不同的许可费用。
比如，本地屏显免费但打印需要额外付费购买许可，我们在本项目中仍然标记为个人免费获取字体许可。

我们在下文中每个字体出现处的上下文做收费、许可限制的有限说明，如没有说明，则表明该字体为使用开源/开放许可证的字体。

### 排除一部分字体

所有 scope 均提供了 `combine` 和 `combine'` 来方便您创建满足自定义条件的字体集。

#### `<scope>.combine`

`combine :: (Derivation -> Bool) -> Derivation` 接收一个 `cond` 条件函数，用于过滤 `<scope>`
中的所有派生满足给定条件的那些。

#### `<scope>.combine'`

`combine :: String -> (Derivation -> Bool) -> Derivation` 接收一个 `name`
作为最终字体集合派生的 `pname`，和一个 `cond`，它和 `<scope>.combine` 的 `cond` 相同。

### 回退到旧版

如果您希望回退固定到旧版 overlay，请使用 `v0.1.0` tag。

```nix
inputs.chinese-fonts-overlay.url = "github:brsvh/chinese-fonts-overlay/v0.1.0";
```

当您想避免`windows-fonts`更新后它那巨大的ISO重建，这可以一定程度上解决，但仍然推荐您保持直接使用 `main` 分支。

## 提供的字体

> [!CAUTION]
>
> 这个仓库提供的字体构建支持包含一些不可再分发的字体，请您避免从本地 store 复制这些字体向他人传播或上传到 substituter server。
>
> - Alibaba Design（Alibaba 字体）- 阿里巴巴（中国）有限公司版权所有的字体；
> - Alimama 字体（阿里妈妈字体）- 淘宝（中国）软件有限公司版权所有的字体；
> - DingTalk 字体（钉钉字体）- 钉钉（中国）信息技术有限公司版权所有的字体；
> - FounderType （方正字库）- 北京北大方正电子有限公司版权所有的字体；
> - Microsoft 字体（微软字体）- 微软股份有限公司版权所有或其分发的字体；
> - Taobao 字体（淘宝字体）- 淘宝（中国）软件有限公司版权所有的字体；
> - TianHeng 字体（TH/天珩字库）- 包含来自中易、华康、Iwata、Besta、方正等字库或公司版权所有的字形；
> - TsangerType 字体（仓耳字体）的商业付费字体 - 北京仓耳文字技术有限公司版权所有的商业付费字体；

### Alibaba Design（Alibaba 字体）- `alibabaPackages`

Alibaba 字体均可以免费用于合法的商业、非商业使用。

> [!TIP]
>
> 通过 `alibaba-fonts` 来安装所有 Alibaba 字体。

- `alibabaPackages.puhuiti` - [阿里巴巴普惠体](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba PuHuiTi Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti%2BAlibaba%20PuHuiTi%20Light.png"
  >
  <br>
  <sub>Alibaba PuHuiTi Light</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti%2BAlibaba%20PuHuiTi%20Regular.png"
  >
  <br>
  <sub>Alibaba PuHuiTi Regular</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti%2BAlibaba%20PuHuiTi%20Medium.png"
  >
  <br>
  <sub>Alibaba PuHuiTi Medium</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti%2BAlibaba%20PuHuiTi%20Bold.png"
  >
  <br>
  <sub>Alibaba PuHuiTi Bold</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi Heavy"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti%2BAlibaba%20PuHuiTi%20Heavy.png"
  >
  <br>
  <sub>Alibaba PuHuiTi Heavy</sub>
  <br>
</p>

- `alibabaPackages.puhuiti2` - [阿里巴巴普惠体2.0](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba PuHuiTi 2.0 35 Thin"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%2035%20Thin.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 35 Thin</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 45 Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%2045%20Light.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 45 Light</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 55 Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%2055%20Regular.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 55 Regular</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 65 Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%2065%20Medium.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 65 Medium</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 75 SemiBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%2075%20SemiBold.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 75 SemiBold</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 85 Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%2085%20Bold.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 85 Bold</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 95 ExtraBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%2095%20ExtraBold.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 95 ExtraBold</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 105 Heavy"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%20105%20Heavy.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 105 Heavy</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 2.0 115 Black"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-2%2BAlibaba%20PuHuiTi%202.0%20115%20Black.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 2.0 115 Black</sub>
  <br>
</p>

- `alibabaPackages.puhuiti3` - [阿里巴巴普惠体3.0](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba PuHuiTi 3.0 35 Thin"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2035%20Thin.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 35 Thin</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 45 Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2045%20Light.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 45 Light</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 55 Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2055%20Regular.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 55 Regular</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 55 Regular L3"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2055%20Regular%20L3.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 55 Regular L3</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 65 Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2065%20Medium.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 65 Medium</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 75 SemiBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2075%20SemiBold.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 75 SemiBold</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 85 Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2085%20Bold.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 85 Bold</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 95 ExtraBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%2095%20ExtraBold.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 95 ExtraBold</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 105 Heavy"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%20105%20Heavy.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 105 Heavy</sub>
  <br>
  <img
    alt="Alibaba PuHuiTi 3.0 115 Black"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-puhuiti-3%2BAlibaba%20PuHuiTi%203.0%20115%20Black.png"
  >
  <br>
  <sub>Alibaba PuHuiTi 3.0 115 Black</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans` -
  [Alibaba Sans](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Light.png"
  >
  <br>
  <sub>Alibaba Sans Light</sub>
  <br>
  <img
    alt="Alibaba Sans Light Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Light%20Italic.png"
  >
  <br>
  <sub>Alibaba Sans Light Italic</sub>
  <br>
  <img
    alt="Alibaba Sans Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans Regular</sub>
  <br>
  <img
    alt="Alibaba Sans Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Italic.png"
  >
  <br>
  <sub>Alibaba Sans Italic</sub>
  <br>
  <img
    alt="Alibaba Sans Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Medium.png"
  >
  <br>
  <sub>Alibaba Sans Medium</sub>
  <br>
  <img
    alt="Alibaba Sans Medium Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Medium%20Italic.png"
  >
  <br>
  <sub>Alibaba Sans Medium Italic</sub>
  <br>
  <img
    alt="Alibaba Sans Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Bold.png"
  >
  <br>
  <sub>Alibaba Sans Bold</sub>
  <br>
  <img
    alt="Alibaba Sans Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Bold%20Italic.png"
  >
  <br>
  <sub>Alibaba Sans Bold Italic</sub>
  <br>
  <img
    alt="Alibaba Sans Heavy"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Heavy.png"
  >
  <br>
  <sub>Alibaba Sans Heavy</sub>
  <br>
  <img
    alt="Alibaba Sans Heavy Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Heavy%20Italic.png"
  >
  <br>
  <sub>Alibaba Sans Heavy Italic</sub>
  <br>
  <img
    alt="Alibaba Sans Black"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans%2BAlibaba%20Sans%20Black.png"
  >
  <br>
  <sub>Alibaba Sans Black</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans-hk` -
  [阿里巴巴普惠體HK](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans HK 45 Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-hk%2BAlibaba%20Sans%20HK%2045%20Light.png"
  >
  <br>
  <sub>Alibaba Sans HK 45 Light</sub>
  <br>
  <img
    alt="Alibaba Sans HK 55 Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-hk%2BAlibaba%20Sans%20HK%2055%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans HK 55 Regular</sub>
  <br>
  <img
    alt="Alibaba Sans HK 75 SemiBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-hk%2BAlibaba%20Sans%20HK%2075%20SemiBold.png"
  >
  <br>
  <sub>Alibaba Sans HK 75 SemiBold</sub>
  <br>
  <img
    alt="Alibaba Sans HK 95 ExtraBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-hk%2BAlibaba%20Sans%20HK%2095%20ExtraBold.png"
  >
  <br>
  <sub>Alibaba Sans HK 95 ExtraBold</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans-jp` -
  [阿里巴巴普惠体日文](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans JP Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-jp%2BAlibaba%20Sans%20JP%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans JP Regular</sub>
  <br>
  <img
    alt="Alibaba Sans JP Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-jp%2BAlibaba%20Sans%20JP%20Medium.png"
  >
  <br>
  <sub>Alibaba Sans JP Medium</sub>
  <br>
  <img
    alt="Alibaba Sans JP Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-jp%2BAlibaba%20Sans%20JP%20Bold.png"
  >
  <br>
  <sub>Alibaba Sans JP Bold</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans-kr` -
  [阿里巴巴普惠体韩文](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans KR Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-kr%2BAlibaba%20Sans%20KR%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans KR Regular</sub>
  <br>
  <img
    alt="Alibaba Sans KR Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-kr%2BAlibaba%20Sans%20KR%20Medium.png"
  >
  <br>
  <sub>Alibaba Sans KR Medium</sub>
  <br>
  <img
    alt="Alibaba Sans KR Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-kr%2BAlibaba%20Sans%20KR%20Bold.png"
  >
  <br>
  <sub>Alibaba Sans KR Bold</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans-sea` -
  [阿里巴巴普惠体SEA](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans SEA Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-sea%2BAlibaba%20Sans%20SEA%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans SEA Regular</sub>
  <br>
  <img
    alt="Alibaba Sans SEA Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-sea%2BAlibaba%20Sans%20SEA%20Medium.png"
  >
  <br>
  <sub>Alibaba Sans SEA Medium</sub>
  <br>
  <img
    alt="Alibaba Sans SEA Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-sea%2BAlibaba%20Sans%20SEA%20Bold.png"
  >
  <br>
  <sub>Alibaba Sans SEA Bold</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans-tc` -
  [阿里巴巴普惠體TC](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans TC 45 Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-tc%2BAlibaba%20Sans%20TC%2045%20Light.png"
  >
  <br>
  <sub>Alibaba Sans TC 45 Light</sub>
  <br>
  <img
    alt="Alibaba Sans TC 55 Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-tc%2BAlibaba%20Sans%20TC%2055%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans TC 55 Regular</sub>
  <br>
  <img
    alt="Alibaba Sans TC 75 SemiBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-tc%2BAlibaba%20Sans%20TC%2075%20SemiBold.png"
  >
  <br>
  <sub>Alibaba Sans TC 75 SemiBold</sub>
  <br>
  <img
    alt="Alibaba Sans TC 95 ExtraBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-tc%2BAlibaba%20Sans%20TC%2095%20ExtraBold.png"
  >
  <br>
  <sub>Alibaba Sans TC 95 ExtraBold</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans-thai` -
  [阿里巴巴普惠体泰文](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans Thai Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-thai%2BAlibaba%20Sans%20Thai%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans Thai Regular</sub>
  <br>
  <img
    alt="Alibaba Sans Thai Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-thai%2BAlibaba%20Sans%20Thai%20Medium.png"
  >
  <br>
  <sub>Alibaba Sans Thai Medium</sub>
  <br>
  <img
    alt="Alibaba Sans Thai Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-thai%2BAlibaba%20Sans%20Thai%20Bold.png"
  >
  <br>
  <sub>Alibaba Sans Thai Bold</sub>
  <br>
</p>

- `alibabaPackages.alibaba-sans-viet` -
  [阿里巴巴普惠体越南文](https://www.alibabafonts.com/#/font)

<p align="center">
  <img
    alt="Alibaba Sans Viet Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-viet%2BAlibaba%20Sans%20Viet%20Regular.png"
  >
  <br>
  <sub>Alibaba Sans Viet Regular</sub>
  <br>
  <img
    alt="Alibaba Sans Viet Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-viet%2BAlibaba%20Sans%20Viet%20Medium.png"
  >
  <br>
  <sub>Alibaba Sans Viet Medium</sub>
  <br>
  <img
    alt="Alibaba Sans Viet Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alibaba/alibaba-sans-viet%2BAlibaba%20Sans%20Viet%20Bold.png"
  >
  <br>
  <sub>Alibaba Sans Viet Bold</sub>
  <br>
</p>

### Alimama 字体（阿里妈妈字体）- `alimamaPackages`

Alimama 字体均可以免费用于合法的商业、非商业使用，唯一的区别是部分不允许嵌入式使用。

> [!TIP]
>
> 通过 `alimama-fonts` 来安装所有 Alimama 字体。

- `alimamaPackages.agile` -
  [阿里妈妈灵动体](https://www.alibabafonts.com/#/more)，允许嵌入式使用

<p align="center">
  <img
    alt="Alimama Agile VF"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alimama/alimama-agile%2BAlimama%20Agile%20VF.png"
  >
</p>

- `alimamaPackages.daoliti` -
  [阿里妈妈刀隶体](https://www.alibabafonts.com/#/more)，允许嵌入式使用

<p align="center">
  <img
    alt="Alimama DaoLiTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alimama/alimama-daoliti%2BAlimama%20DaoLiTi.png"
  >
</p>

- `alimamaPackages.dongfangdakai` -
  [阿里妈妈东方大楷](https://www.alibabafonts.com/#/more)，不允许嵌入式使用

<p align="center">
  <img
    alt="Alimama DongFangDaKai"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alimama/alimama-dongfangdakai%2BAlimama%20DongFangDaKai.png"
  >
</p>

- `alimamaPackages.fangyuanti` -
  [阿里妈妈方圆体](https://www.alibabafonts.com/#/more)，允许嵌入式使用

<p align="center">
  <img
    alt="Alimama FangYuanTi VF"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alimama/alimama-fangyuanti%2BAlimama%20FangYuanTi%20VF.png"
  >
</p>

- `alimamaPackages.shuheiti` -
  [阿里妈妈数黑体](https://www.alibabafonts.com/#/more)，不允许嵌入式使用

<p align="center">
  <img
    alt="Alimama ShuHeiTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/alimama/alimama-shuheiti%2BAlimama%20ShuHeiTi.png"
  >
</p>

### DingTalk 字体（钉钉字体）- `dingtalkPackages`

DingTalk 字体均可以免费用于合法的商业、非商业使用。

> [!TIP]
>
> 通过 `dingtalk-fonts` 来安装所有 DingTalk 字体。

- `dingtalkPackages.jinbuti` -
  [钉钉进步体](https://www.alibabafonts.com/#/more)\*，不允许嵌入式使用

<p align="center">
  <img
    alt="DingTalk JinBuTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/dingtalk/dingtalk-jinbuti%2BDingTalk%20JinBuTi.png"
  >
</p>

> \*：该字体的网站许可（语雀文档）链接指向了某个普惠体目录下的链接，但无法查看，
> 故假设其具有相似的商业与非商业使用授权范围，并按不允许嵌入式使用保守推断。具体使用情形，您应当谨慎的从最保守的情况做考虑。

### FounderType 字库（方正字库）- `foundertypePackages`

`foundertype-fonts` 提供方正字库的字体，这些字体的协议包括以下情形。

1. 个人免费字体，需要获得方正个人非商业授权 [^1] 才能使用的字体，这一许可过程无须付费。
2. 商业免费字体，需要额外获取方正商业发布授权 [^2] 但无须支付费用就能使用的字体。
3. 付费字体，需要额外获取方正商业发布授权 [^2] 并为具体使用支付额外费用才能使用的字体。

这些情形，不论如何，您均需要通过方正字库官网获得授权许可后才能进行构建和使用。

#### 商用免费字体

`foundertype-gcu-fonts` 提供方正字库的所有商用免费字体。

- `foundertypePackages.fzfangsong` -
  [方正仿宋](https://www.foundertype.com/index.php/FontInfo/index/id/128)

<p align="center">
  <img
    alt="FZFangSong-Z02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzfangsong%2BFZFangSong-Z02.png"
  >
</p>

- `foundertypePackages.fzheiti` -
  [方正黑体](https://www.foundertype.com/index.php/FontInfo/index/id/131)

<p align="center">
  <img
    alt="FZHei-B01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzheiti%2BFZHei-B01.png"
  >
</p>

- `foundertypePackages.fzkaiti` -
  [方正楷体](https://www.foundertype.com/index.php/FontInfo/index/id/137)

<p align="center">
  <img
    alt="FZKai-Z03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzkaiti%2BFZKai-Z03.png"
  >
</p>

- `foundertypePackages.fzshusong` -
  [方正书宋](https://www.foundertype.com/index.php/FontInfo/index/id/151)

<p align="center">
  <img
    alt="FZShuSong-Z01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzshusong%2BFZShuSong-Z01.png"
  >
</p>

> [!NOTE]
>
> 当前缺少方正甲骨文字体，它同样是商用免费字体。

#### 个人免费字体

`foundertype-gpu-fonts` 提供方正字库的所有个人免费字体（包括商用免费字体）。

- `foundertypePackages.fzfangsong` -
  [方正仿宋](https://www.foundertype.com/index.php/FontInfo/index/id/128)

<p align="center">
  <img
    alt="FZFangSong-Z02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzfangsong%2BFZFangSong-Z02.png"
  >
</p>

- `foundertypePackages.fzheiti` -
  [方正黑体](https://www.foundertype.com/index.php/FontInfo/index/id/131)

<p align="center">
  <img
    alt="FZHei-B01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzheiti%2BFZHei-B01.png"
  >
</p>

- `foundertypePackages.fzkaiti` -
  [方正楷体](https://www.foundertype.com/index.php/FontInfo/index/id/137)

<p align="center">
  <img
    alt="FZKai-Z03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzkaiti%2BFZKai-Z03.png"
  >
</p>

- `foundertypePackages.fzshusong` -
  [方正书宋](https://www.foundertype.com/index.php/FontInfo/index/id/151)

<p align="center">
  <img
    alt="FZShuSong-Z01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzshusong%2BFZShuSong-Z01.png"
  >
</p>

> [!NOTE]
>
> 当前缺少这些字体，它们被标明为个人非商用免费字体。
>
> - 方正字迹-青柠体
> - 方正雕版宋
> - 方正云流体

#### 付费字体

> [!CAUTION]
>
> 下列的字体均需要付费获取授权，请您在使用前在方正字库官方网站购买这些字体的使用授权后再在本地进行构建。否则您需要自行承担相关的法律风险。

> [!TIP]
>
> 通过 `foundertype-paid-fonts` 来安装所有付费 FounderType 字体。

- `foundertypePackages.fzlishu` -
  [方正隶书](https://www.foundertype.com/index.php/FontInfo/index/id/141)

<p align="center">
  <img
    alt="FZLiShu-S01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzlishu%2BFZLiShu-S01.png"
  >
</p>

- `foundertypePackages.fzxiheiyi` -
  [方正细黑一](https://www.foundertype.com/index.php/FontInfo/index/id/161)

<p align="center">
  <img
    alt="FZXiHeiI-Z08"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzxiheiyi%2BFZXiHeiI-Z08.png"
  >
</p>

- `foundertypePackages.fzxiyuan` -
  [方正细圆](https://www.foundertype.com/index.php/FontInfo/index/id/179)

<p align="center">
  <img
    alt="FZXiYuan-M01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzxiyuan%2BFZXiYuan-M01.png"
  >
</p>

- `foundertypePackages.fzzhunyuan` -
  [方正准圆](https://www.foundertype.com/index.php/FontInfo/index/id/179)

<p align="center">
  <img
    alt="FZZhunYuan-M02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzzhunyuan%2BFZZhunYuan-M02.png"
  >
</p>

- `foundertypePackages.fzcuyuan` -
  [方正粗圆](https://www.foundertype.com/index.php/FontInfo/index/id/179)

<p align="center">
  <img
    alt="FZCuYuan-M03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzcuyuan%2BFZCuYuan-M03.png"
  >
</p>

- `foundertypePackages.fzxiaobiaosong` -
  [方正小标宋](https://www.foundertype.com/index.php/FontInfo/index/id/164)

<p align="center">
  <img
    alt="FZXiaoBiaoSong-B05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzxiaobiaosong%2BFZXiaoBiaoSong-B05.png"
  >
</p>

#### CTeX `founder` fontset 需要的 Foundertype 字体

> [!TIP]
>
> 通过 `foundertype-ctex-fonts` 来安装
> [CTeX](https://github.com/CTeX-org/ctex-kit/blob/97497041f42c45609e14f65de596636363d71ef6/ctex/ctex.dtx)
> 中 `founder` fontset 需要的字体。

包括下列字体：

- `foundertypePackages.fzshusong` -
  [方正书宋](https://www.foundertype.com/index.php/FontInfo/index/id/151)

<p align="center">
  <img
    alt="FZShuSong-Z01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzshusong%2BFZShuSong-Z01.png"
  >
</p>

- `foundertypePackages.fzxiaobiaosong` -
  [方正小标宋](https://www.foundertype.com/index.php/FontInfo/index/id/164)

<p align="center">
  <img
    alt="FZXiaoBiaoSong-B05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzxiaobiaosong%2BFZXiaoBiaoSong-B05.png"
  >
</p>

- `foundertypePackages.fzkaiti` -
  [方正楷体](https://www.foundertype.com/index.php/FontInfo/index/id/137)

<p align="center">
  <img
    alt="FZKai-Z03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzkaiti%2BFZKai-Z03.png"
  >
</p>

- `foundertypePackages.fzxiheiyi` -
  [方正细黑一](https://www.foundertype.com/index.php/FontInfo/index/id/161)

<p align="center">
  <img
    alt="FZXiHeiI-Z08"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzxiheiyi%2BFZXiHeiI-Z08.png"
  >
</p>

- `foundertypePackages.fzheiti` -
  [方正黑体](https://www.foundertype.com/index.php/FontInfo/index/id/131)

<p align="center">
  <img
    alt="FZHei-B01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzheiti%2BFZHei-B01.png"
  >
</p>

- `foundertypePackages.fzfangsong` -
  [方正仿宋](https://www.foundertype.com/index.php/FontInfo/index/id/128)

<p align="center">
  <img
    alt="FZFangSong-Z02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzfangsong%2BFZFangSong-Z02.png"
  >
</p>

- `foundertypePackages.fzlishu` -
  [方正隶书](https://www.foundertype.com/index.php/FontInfo/index/id/141)

<p align="center">
  <img
    alt="FZLiShu-S01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzlishu%2BFZLiShu-S01.png"
  >
</p>

- `foundertypePackages.fzxiyuan` -
  [方正细圆](https://www.foundertype.com/index.php/FontInfo/index/id/179)

<p align="center">
  <img
    alt="FZXiYuan-M01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzxiyuan%2BFZXiYuan-M01.png"
  >
</p>

- `foundertypePackages.fzzhunyuan` -
  [方正准圆](https://www.foundertype.com/index.php/FontInfo/index/id/179)

<p align="center">
  <img
    alt="FZZhunYuan-M02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/foundertype/foundertype-fzzhunyuan%2BFZZhunYuan-M02.png"
  >
</p>

### Justfont 字体 - `justfontPackages`

> [!TIP]
>
> 通过 `justfont-fonts` 来安装所有 Justfont 字体。

- `justfontPackages.abbrfesfont` -
  [簡語生活體 AbbrFesFont](https://justfont.com/justforfun/abbrfesfont)

<p align="center">
  <img
    alt="AbbrFesFont"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-abbrfesfont%2BAbbrFesFont.png"
  >
</p>

- `justfontPackages.allpuntype` -
  [諧靈附體 AllPunType](https://github.com/justfont/AllPunType)

<p align="center">
  <img
    alt="AllPunType ExtraLight"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-allpuntype%2BAllPunType%20ExtraLight.png"
  >
  <br>
  <sub>AllPunType ExtraLight</sub>
  <br>
  <img
    alt="AllPunType Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-allpuntype%2BAllPunType%20Light.png"
  >
  <br>
  <sub>AllPunType Light</sub>
  <br>
  <img
    alt="AllPunType Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-allpuntype%2BAllPunType%20Regular.png"
  >
  <br>
  <sub>AllPunType Regular</sub>
  <br>
  <img
    alt="AllPunType Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-allpuntype%2BAllPunType%20Medium.png"
  >
  <br>
  <sub>AllPunType Medium</sub>
  <br>
  <img
    alt="AllPunType SemiBold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-allpuntype%2BAllPunType%20SemiBold.png"
  >
  <br>
  <sub>AllPunType SemiBold</sub>
  <br>
  <img
    alt="AllPunType Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-allpuntype%2BAllPunType%20Bold.png"
  >
  <br>
  <sub>AllPunType Bold</sub>
  <br>
  <img
    alt="AllPunType Heavy"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-allpuntype%2BAllPunType%20Heavy.png"
  >
  <br>
  <sub>AllPunType Heavy</sub>
  <br>
</p>

- `justfontPackages.elffont` - [精靈文 Elffont](https://ref.justfont.com/gRbXjtF)

<p align="center">
  <img
    alt="elffont fern"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-elffont%2Belffont%20fern.png"
  >
  <br>
  <sub>elffont fern</sub>
  <br>
  <img
    alt="elffont rock"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-elffont%2Belffont%20rock.png"
  >
  <br>
  <sub>elffont rock</sub>
  <br>
</p>

- `justfontPackages.huninn` - [Huninn / 粉圓](https://github.com/justfont/Huninn)

<p align="center">
  <img
    alt="Huninn"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-huninn%2BHuninn.png"
  >
</p>

- `justfontPackages.the-write-right-font` -
  [就是不錯字（吧） The Write Right Font](https://github.com/justfont/The-Write-Right-Font)

<p align="center">
  <img
    alt="The Write Right Font"
    src="https://user-images.githubusercontent.com/129033985/229058895-6b4d0c07-fff8-4dde-a608-647275863ff7.gif"
  >
</p>

- `justfontPackages.type-jam` - [草率手寫體 Type Jam](https://typejam.justfont.com/)

<p align="center">
  <img
    alt="Type Jam"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-type-jam%2BType%20Jam.png"
  >
</p>

- `justfontPackages.snailfont` -
  [螺體 Snail Font](https://justfont.com/justforfun/snail-font)

<p align="center">
  <img
    alt="snailfont Sinotaia"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-snailfont%2Bsnailfont%20Sinotaia.png"
  >
  <br>
  <sub>snailfont Sinotaia</sub>
  <br>
  <img
    alt="snailfont Pomacea"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/justfont/justfont-snailfont%2Bsnailfont%20Pomacea.png"
  >
  <br>
  <sub>snailfont Pomacea</sub>
  <br>
</p>

### Microsoft 字体（微软字体）- `microsoftPackages`

> [!CAUTION]
>
> Microsoft 字体是专有软件，受 Microsoft Software License Terms 约束。
> 这个仓库只提供本地构建与安装表达式，不授予额外使用或再分发权利。
>
> 相关限制可以概括为：您不能在非 Windows 设备上使用它们。
>
> 建议您只在 Windows Subsystem for Linux (WSL) 上使用它。

> [!TIP]
>
> 通过 `windows-fonts` 安装 Windows 11 zh-CN ISO 中的所有 Microsoft 字体。

- `microsoftPackages.arial` -
  [Arial / Arial Black](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Arial Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-arial%2BArial%20Regular.png"
  >
  <br>
  <sub>Arial Regular</sub>
  <br>
  <img
    alt="Arial Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-arial%2BArial%20Italic.png"
  >
  <br>
  <sub>Arial Italic</sub>
  <br>
  <img
    alt="Arial Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-arial%2BArial%20Bold.png"
  >
  <br>
  <sub>Arial Bold</sub>
  <br>
  <img
    alt="Arial Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-arial%2BArial%20Bold%20Italic.png"
  >
  <br>
  <sub>Arial Bold Italic</sub>
  <br>
  <img
    alt="Arial Black"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-arial%2BArial%20Black.png"
  >
  <br>
  <sub>Arial Black</sub>
  <br>
</p>

- `microsoftPackages.bahnschrift` -
  [Bahnschrift](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Bahnschrift"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-bahnschrift%2BBahnschrift.png"
  >
</p>

- `microsoftPackages.calibri` -
  [Calibri / Calibri Light](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Calibri Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-calibri%2BCalibri%20Light.png"
  >
  <br>
  <sub>Calibri Light</sub>
  <br>
  <img
    alt="Calibri Light Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-calibri%2BCalibri%20Light%20Italic.png"
  >
  <br>
  <sub>Calibri Light Italic</sub>
  <br>
  <img
    alt="Calibri Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-calibri%2BCalibri%20Regular.png"
  >
  <br>
  <sub>Calibri Regular</sub>
  <br>
  <img
    alt="Calibri Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-calibri%2BCalibri%20Italic.png"
  >
  <br>
  <sub>Calibri Italic</sub>
  <br>
  <img
    alt="Calibri Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-calibri%2BCalibri%20Bold.png"
  >
  <br>
  <sub>Calibri Bold</sub>
  <br>
  <img
    alt="Calibri Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-calibri%2BCalibri%20Bold%20Italic.png"
  >
  <br>
  <sub>Calibri Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.cambria` -
  [Cambria](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Cambria Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-cambria%2BCambria%20Regular.png"
  >
  <br>
  <sub>Cambria Regular</sub>
  <br>
  <img
    alt="Cambria Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-cambria%2BCambria%20Italic.png"
  >
  <br>
  <sub>Cambria Italic</sub>
  <br>
  <img
    alt="Cambria Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-cambria%2BCambria%20Bold.png"
  >
  <br>
  <sub>Cambria Bold</sub>
  <br>
  <img
    alt="Cambria Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-cambria%2BCambria%20Bold%20Italic.png"
  >
  <br>
  <sub>Cambria Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.cambria-math` -
  [Cambria Math](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Cambria"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-cambria-math%2BCambria.png"
  >
</p>

- `microsoftPackages.candara` -
  [Candara / Candara Light](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Candara Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-candara%2BCandara%20Light.png"
  >
  <br>
  <sub>Candara Light</sub>
  <br>
  <img
    alt="Candara Light Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-candara%2BCandara%20Light%20Italic.png"
  >
  <br>
  <sub>Candara Light Italic</sub>
  <br>
  <img
    alt="Candara Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-candara%2BCandara%20Regular.png"
  >
  <br>
  <sub>Candara Regular</sub>
  <br>
  <img
    alt="Candara Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-candara%2BCandara%20Italic.png"
  >
  <br>
  <sub>Candara Italic</sub>
  <br>
  <img
    alt="Candara Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-candara%2BCandara%20Bold.png"
  >
  <br>
  <sub>Candara Bold</sub>
  <br>
  <img
    alt="Candara Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-candara%2BCandara%20Bold%20Italic.png"
  >
  <br>
  <sub>Candara Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.comic-sans-ms` -
  [Comic Sans MS](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Comic Sans MS Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-comic-sans-ms%2BComic%20Sans%20MS%20Regular.png"
  >
  <br>
  <sub>Comic Sans MS Regular</sub>
  <br>
  <img
    alt="Comic Sans MS Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-comic-sans-ms%2BComic%20Sans%20MS%20Italic.png"
  >
  <br>
  <sub>Comic Sans MS Italic</sub>
  <br>
  <img
    alt="Comic Sans MS Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-comic-sans-ms%2BComic%20Sans%20MS%20Bold.png"
  >
  <br>
  <sub>Comic Sans MS Bold</sub>
  <br>
  <img
    alt="Comic Sans MS Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-comic-sans-ms%2BComic%20Sans%20MS%20Bold%20Italic.png"
  >
  <br>
  <sub>Comic Sans MS Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.consolas` -
  [Consolas](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Consolas Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-consolas%2BConsolas%20Regular.png"
  >
  <br>
  <sub>Consolas Regular</sub>
  <br>
  <img
    alt="Consolas Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-consolas%2BConsolas%20Italic.png"
  >
  <br>
  <sub>Consolas Italic</sub>
  <br>
  <img
    alt="Consolas Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-consolas%2BConsolas%20Bold.png"
  >
  <br>
  <sub>Consolas Bold</sub>
  <br>
  <img
    alt="Consolas Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-consolas%2BConsolas%20Bold%20Italic.png"
  >
  <br>
  <sub>Consolas Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.constantia` -
  [Constantia](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Constantia Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-constantia%2BConstantia%20Regular.png"
  >
  <br>
  <sub>Constantia Regular</sub>
  <br>
  <img
    alt="Constantia Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-constantia%2BConstantia%20Italic.png"
  >
  <br>
  <sub>Constantia Italic</sub>
  <br>
  <img
    alt="Constantia Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-constantia%2BConstantia%20Bold.png"
  >
  <br>
  <sub>Constantia Bold</sub>
  <br>
  <img
    alt="Constantia Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-constantia%2BConstantia%20Bold%20Italic.png"
  >
  <br>
  <sub>Constantia Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.corbel` -
  [Corbel / Corbel Light](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Corbel Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-corbel%2BCorbel%20Light.png"
  >
  <br>
  <sub>Corbel Light</sub>
  <br>
  <img
    alt="Corbel Light Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-corbel%2BCorbel%20Light%20Italic.png"
  >
  <br>
  <sub>Corbel Light Italic</sub>
  <br>
  <img
    alt="Corbel Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-corbel%2BCorbel%20Regular.png"
  >
  <br>
  <sub>Corbel Regular</sub>
  <br>
  <img
    alt="Corbel Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-corbel%2BCorbel%20Italic.png"
  >
  <br>
  <sub>Corbel Italic</sub>
  <br>
  <img
    alt="Corbel Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-corbel%2BCorbel%20Bold.png"
  >
  <br>
  <sub>Corbel Bold</sub>
  <br>
  <img
    alt="Corbel Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-corbel%2BCorbel%20Bold%20Italic.png"
  >
  <br>
  <sub>Corbel Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.courier-new` -
  [Courier New](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Courier New Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-courier-new%2BCourier%20New%20Regular.png"
  >
  <br>
  <sub>Courier New Regular</sub>
  <br>
  <img
    alt="Courier New Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-courier-new%2BCourier%20New%20Italic.png"
  >
  <br>
  <sub>Courier New Italic</sub>
  <br>
  <img
    alt="Courier New Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-courier-new%2BCourier%20New%20Bold.png"
  >
  <br>
  <sub>Courier New Bold</sub>
  <br>
  <img
    alt="Courier New Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-courier-new%2BCourier%20New%20Bold%20Italic.png"
  >
  <br>
  <sub>Courier New Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.dengxian` -
  [DengXian / 等线](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="DengXian Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-dengxian%2BDengXian%20Light.png"
  >
  <br>
  <sub>DengXian Light</sub>
  <br>
  <img
    alt="DengXian Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-dengxian%2BDengXian%20Regular.png"
  >
  <br>
  <sub>DengXian Regular</sub>
  <br>
  <img
    alt="DengXian Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-dengxian%2BDengXian%20Bold.png"
  >
  <br>
  <sub>DengXian Bold</sub>
  <br>
</p>

- `microsoftPackages.ebrima` -
  [Ebrima](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Ebrima Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-ebrima%2BEbrima%20Regular.png"
  >
  <br>
  <sub>Ebrima Regular</sub>
  <br>
  <img
    alt="Ebrima Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-ebrima%2BEbrima%20Bold.png"
  >
  <br>
  <sub>Ebrima Bold</sub>
  <br>
</p>

- `microsoftPackages.fangsong` -
  [FangSong / 仿宋](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="FangSong"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-fangsong%2BFangSong.png"
  >
</p>

- `microsoftPackages.franklin-gothic-medium` -
  [Franklin Gothic Medium](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Franklin Gothic Medium Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-franklin-gothic-medium%2BFranklin%20Gothic%20Medium%20Regular.png"
  >
  <br>
  <sub>Franklin Gothic Medium Regular</sub>
  <br>
  <img
    alt="Franklin Gothic Medium Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-franklin-gothic-medium%2BFranklin%20Gothic%20Medium%20Italic.png"
  >
  <br>
  <sub>Franklin Gothic Medium Italic</sub>
  <br>
</p>

- `microsoftPackages.gabriola` -
  [Gabriola](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Gabriola"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-gabriola%2BGabriola.png"
  >
</p>

- `microsoftPackages.gadugi` -
  [Gadugi](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Gadugi Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-gadugi%2BGadugi%20Regular.png"
  >
  <br>
  <sub>Gadugi Regular</sub>
  <br>
  <img
    alt="Gadugi Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-gadugi%2BGadugi%20Bold.png"
  >
  <br>
  <sub>Gadugi Bold</sub>
  <br>
</p>

- `microsoftPackages.georgia` -
  [Georgia](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Georgia Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-georgia%2BGeorgia%20Regular.png"
  >
  <br>
  <sub>Georgia Regular</sub>
  <br>
  <img
    alt="Georgia Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-georgia%2BGeorgia%20Italic.png"
  >
  <br>
  <sub>Georgia Italic</sub>
  <br>
  <img
    alt="Georgia Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-georgia%2BGeorgia%20Bold.png"
  >
  <br>
  <sub>Georgia Bold</sub>
  <br>
  <img
    alt="Georgia Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-georgia%2BGeorgia%20Bold%20Italic.png"
  >
  <br>
  <sub>Georgia Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.impact` -
  [Impact](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Impact"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-impact%2BImpact.png"
  >
</p>

- `microsoftPackages.ink-free` -
  [Ink Free](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Ink Free"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-ink-free%2BInk%20Free.png"
  >
</p>

- `microsoftPackages.javanese-text` -
  [Javanese Text](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Javanese Text"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-javanese-text%2BJavanese%20Text.png"
  >
</p>

- `microsoftPackages.kaiti` -
  [KaiTi / 楷体](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="KaiTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-kaiti%2BKaiTi.png"
  >
</p>

- `microsoftPackages.leelawadee-ui` -
  [Leelawadee UI](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Leelawadee UI Semilight"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-leelawadee-ui%2BLeelawadee%20UI%20Semilight.png"
  >
  <br>
  <sub>Leelawadee UI Semilight</sub>
  <br>
  <img
    alt="Leelawadee UI Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-leelawadee-ui%2BLeelawadee%20UI%20Regular.png"
  >
  <br>
  <sub>Leelawadee UI Regular</sub>
  <br>
  <img
    alt="Leelawadee UI Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-leelawadee-ui%2BLeelawadee%20UI%20Bold.png"
  >
  <br>
  <sub>Leelawadee UI Bold</sub>
  <br>
</p>

- `microsoftPackages.lucida-console` -
  [Lucida Console](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Lucida Console"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-lucida-console%2BLucida%20Console.png"
  >
</p>

- `microsoftPackages.lucida-sans-unicode` -
  [Lucida Sans Unicode](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Lucida Sans Unicode"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-lucida-sans-unicode%2BLucida%20Sans%20Unicode.png"
  >
</p>

- `microsoftPackages.malgun-gothic` -
  [Malgun Gothic](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Malgun Gothic Semilight"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-malgun-gothic%2BMalgun%20Gothic%20Semilight.png"
  >
  <br>
  <sub>Malgun Gothic Semilight</sub>
  <br>
  <img
    alt="Malgun Gothic Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-malgun-gothic%2BMalgun%20Gothic%20Regular.png"
  >
  <br>
  <sub>Malgun Gothic Regular</sub>
  <br>
  <img
    alt="Malgun Gothic Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-malgun-gothic%2BMalgun%20Gothic%20Bold.png"
  >
  <br>
  <sub>Malgun Gothic Bold</sub>
  <br>
</p>

- `microsoftPackages.marlett` -
  [Marlett](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Marlett"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-marlett%2BMarlett.png"
  >
</p>

- `microsoftPackages.microsoft-himalaya` -
  [Microsoft Himalaya](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft Himalaya"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-himalaya%2BMicrosoft%20Himalaya.png"
  >
</p>

- `microsoftPackages.microsoft-jhenghei` -
  [Microsoft JhengHei / Microsoft JhengHei UI / 微軟正黑體](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft JhengHei Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-jhenghei%2BMicrosoft%20JhengHei%20Light.png"
  >
  <br>
  <sub>Microsoft JhengHei Light</sub>
  <br>
  <img
    alt="Microsoft JhengHei Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-jhenghei%2BMicrosoft%20JhengHei%20Regular.png"
  >
  <br>
  <sub>Microsoft JhengHei Regular</sub>
  <br>
  <img
    alt="Microsoft JhengHei Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-jhenghei%2BMicrosoft%20JhengHei%20Bold.png"
  >
  <br>
  <sub>Microsoft JhengHei Bold</sub>
  <br>
</p>

- `microsoftPackages.microsoft-new-tai-lue` -
  [Microsoft New Tai Lue](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft New Tai Lue Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-new-tai-lue%2BMicrosoft%20New%20Tai%20Lue%20Regular.png"
  >
  <br>
  <sub>Microsoft New Tai Lue Regular</sub>
  <br>
  <img
    alt="Microsoft New Tai Lue Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-new-tai-lue%2BMicrosoft%20New%20Tai%20Lue%20Bold.png"
  >
  <br>
  <sub>Microsoft New Tai Lue Bold</sub>
  <br>
</p>

- `microsoftPackages.microsoft-phagspa` -
  [Microsoft PhagsPa](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft PhagsPa Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-phagspa%2BMicrosoft%20PhagsPa%20Regular.png"
  >
  <br>
  <sub>Microsoft PhagsPa Regular</sub>
  <br>
  <img
    alt="Microsoft PhagsPa Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-phagspa%2BMicrosoft%20PhagsPa%20Bold.png"
  >
  <br>
  <sub>Microsoft PhagsPa Bold</sub>
  <br>
</p>

- `microsoftPackages.microsoft-sans-serif` -
  [Microsoft Sans Serif](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft Sans Serif"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-sans-serif%2BMicrosoft%20Sans%20Serif.png"
  >
</p>

- `microsoftPackages.microsoft-tai-le` -
  [Microsoft Tai Le](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft Tai Le Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-tai-le%2BMicrosoft%20Tai%20Le%20Regular.png"
  >
  <br>
  <sub>Microsoft Tai Le Regular</sub>
  <br>
  <img
    alt="Microsoft Tai Le Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-tai-le%2BMicrosoft%20Tai%20Le%20Bold.png"
  >
  <br>
  <sub>Microsoft Tai Le Bold</sub>
  <br>
</p>

- `microsoftPackages.microsoft-yahei` -
  [Microsoft YaHei / Microsoft YaHei UI / 微软雅黑](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft YaHei Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-yahei%2BMicrosoft%20YaHei%20Light.png"
  >
  <br>
  <sub>Microsoft YaHei Light</sub>
  <br>
  <img
    alt="Microsoft YaHei Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-yahei%2BMicrosoft%20YaHei%20Regular.png"
  >
  <br>
  <sub>Microsoft YaHei Regular</sub>
  <br>
  <img
    alt="Microsoft YaHei Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-yahei%2BMicrosoft%20YaHei%20Bold.png"
  >
  <br>
  <sub>Microsoft YaHei Bold</sub>
  <br>
</p>

- `microsoftPackages.microsoft-yi-baiti` -
  [Microsoft Yi Baiti](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Microsoft Yi Baiti"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-microsoft-yi-baiti%2BMicrosoft%20Yi%20Baiti.png"
  >
</p>

- `microsoftPackages.mingliu` -
  [MingLiU-ExtB / PMingLiU-ExtB / MingLiU_HKSCS-ExtB / MingLiU_MSCS-ExtB](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

- `microsoftPackages.mongolian-baiti` -
  [Mongolian Baiti](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Mongolian Baiti"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-mongolian-baiti%2BMongolian%20Baiti.png"
  >
</p>

- `microsoftPackages.ms-gothic` -
  [MS Gothic / MS PGothic / MS UI Gothic](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="MS Gothic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-ms-gothic%2BMS%20Gothic.png"
  >
</p>

- `microsoftPackages.mv-boli` -
  [MV Boli](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="MV Boli"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-mv-boli%2BMV%20Boli.png"
  >
</p>

- `microsoftPackages.myanmar-text` -
  [Myanmar Text](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Myanmar Text Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-myanmar-text%2BMyanmar%20Text%20Bold.png"
  >
  <br>
  <sub>Myanmar Text Bold</sub>
  <br>
  <img
    alt="Myanmar Text Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-myanmar-text%2BMyanmar%20Text%20Regular.png"
  >
  <br>
  <sub>Myanmar Text Regular</sub>
  <br>
</p>

- `microsoftPackages.nirmala` -
  [Nirmala Text / Nirmala UI](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Nirmala UI"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-nirmala%2BNirmala%20UI.png"
  >
</p>

- `microsoftPackages.noto-sans-sc` -
  [Noto Sans SC](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Noto Sans SC"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-noto-sans-sc%2BNoto%20Sans%20SC.png"
  >
</p>

- `microsoftPackages.noto-serif-sc` -
  [Noto Serif SC](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Noto Serif SC"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-noto-serif-sc%2BNoto%20Serif%20SC.png"
  >
</p>

- `microsoftPackages.palatino-linotype` -
  [Palatino Linotype](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Palatino Linotype Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-palatino-linotype%2BPalatino%20Linotype%20Regular.png"
  >
  <br>
  <sub>Palatino Linotype Regular</sub>
  <br>
  <img
    alt="Palatino Linotype Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-palatino-linotype%2BPalatino%20Linotype%20Italic.png"
  >
  <br>
  <sub>Palatino Linotype Italic</sub>
  <br>
  <img
    alt="Palatino Linotype Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-palatino-linotype%2BPalatino%20Linotype%20Bold.png"
  >
  <br>
  <sub>Palatino Linotype Bold</sub>
  <br>
  <img
    alt="Palatino Linotype Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-palatino-linotype%2BPalatino%20Linotype%20Bold%20Italic.png"
  >
  <br>
  <sub>Palatino Linotype Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.sans-serif-collection` -
  [Sans Serif Collection](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Sans Serif Collection"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-sans-serif-collection%2BSans%20Serif%20Collection.png"
  >
</p>

- `microsoftPackages.segoe-icons` -
  [Segoe Fluent Icons / Segoe MDL2 Assets](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Segoe Fluent Icons"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-icons%2BSegoe%20Fluent%20Icons.png"
  >
  <br>
  <sub>Segoe Fluent Icons</sub>
  <br>
  <img
    alt="Segoe MDL2 Assets"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-icons%2BSegoe%20MDL2%20Assets.png"
  >
  <br>
  <sub>Segoe MDL2 Assets</sub>
  <br>
</p>

- `microsoftPackages.segoe-print` -
  [Segoe Print](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Segoe Print Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-print%2BSegoe%20Print%20Regular.png"
  >
  <br>
  <sub>Segoe Print Regular</sub>
  <br>
  <img
    alt="Segoe Print Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-print%2BSegoe%20Print%20Bold.png"
  >
  <br>
  <sub>Segoe Print Bold</sub>
  <br>
</p>

- `microsoftPackages.segoe-script` -
  [Segoe Script](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Segoe Script Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-script%2BSegoe%20Script%20Regular.png"
  >
  <br>
  <sub>Segoe Script Regular</sub>
  <br>
  <img
    alt="Segoe Script Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-script%2BSegoe%20Script%20Bold.png"
  >
  <br>
  <sub>Segoe Script Bold</sub>
  <br>
</p>

- `microsoftPackages.segoe-ui` -
  [Segoe UI](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Segoe UI Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Light.png"
  >
  <br>
  <sub>Segoe UI Light</sub>
  <br>
  <img
    alt="Segoe UI Light Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Light%20Italic.png"
  >
  <br>
  <sub>Segoe UI Light Italic</sub>
  <br>
  <img
    alt="Segoe UI Semilight"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Semilight.png"
  >
  <br>
  <sub>Segoe UI Semilight</sub>
  <br>
  <img
    alt="Segoe UI Semilight Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Semilight%20Italic.png"
  >
  <br>
  <sub>Segoe UI Semilight Italic</sub>
  <br>
  <img
    alt="Segoe UI Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Regular.png"
  >
  <br>
  <sub>Segoe UI Regular</sub>
  <br>
  <img
    alt="Segoe UI Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Italic.png"
  >
  <br>
  <sub>Segoe UI Italic</sub>
  <br>
  <img
    alt="Segoe UI Semibold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Semibold.png"
  >
  <br>
  <sub>Segoe UI Semibold</sub>
  <br>
  <img
    alt="Segoe UI Semibold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Semibold%20Italic.png"
  >
  <br>
  <sub>Segoe UI Semibold Italic</sub>
  <br>
  <img
    alt="Segoe UI Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Bold.png"
  >
  <br>
  <sub>Segoe UI Bold</sub>
  <br>
  <img
    alt="Segoe UI Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Bold%20Italic.png"
  >
  <br>
  <sub>Segoe UI Bold Italic</sub>
  <br>
  <img
    alt="Segoe UI Black"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Black.png"
  >
  <br>
  <sub>Segoe UI Black</sub>
  <br>
  <img
    alt="Segoe UI Black Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui%2BSegoe%20UI%20Black%20Italic.png"
  >
  <br>
  <sub>Segoe UI Black Italic</sub>
  <br>
</p>

- `microsoftPackages.segoe-ui-symbols` -
  [Segoe UI Emoji / Segoe UI Historic / Segoe UI Symbol](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Segoe UI Emoji"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui-symbols%2BSegoe%20UI%20Emoji.png"
  >
  <br>
  <sub>Segoe UI Emoji</sub>
  <br>
  <img
    alt="Segoe UI Historic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui-symbols%2BSegoe%20UI%20Historic.png"
  >
  <br>
  <sub>Segoe UI Historic</sub>
  <br>
  <img
    alt="Segoe UI Symbol"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui-symbols%2BSegoe%20UI%20Symbol.png"
  >
  <br>
  <sub>Segoe UI Symbol</sub>
  <br>
</p>

- `microsoftPackages.segoe-ui-variable` -
  [Segoe UI Variable](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Segoe UI Variable"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-segoe-ui-variable%2BSegoe%20UI%20Variable.png"
  >
</p>

- `microsoftPackages.simhei` -
  [SimHei / 黑体](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="SimHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-simhei%2BSimHei.png"
  >
</p>

- `microsoftPackages.simsun` -
  [SimSun / NSimSun / SimSun-ExtB / SimSun-ExtG / 宋体 / 新宋体](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="SimSun"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-simsun%2BSimSun.png"
  >
</p>

- `microsoftPackages.sitka` -
  [Sitka](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Sitka Text"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-sitka%2BSitka%20Text.png"
  >
  <br>
  <sub>Sitka Text</sub>
  <br>
  <img
    alt="Sitka Text Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-sitka%2BSitka%20Text%20Italic.png"
  >
  <br>
  <sub>Sitka Text Italic</sub>
  <br>
</p>

- `microsoftPackages.sylfaen` -
  [Sylfaen](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Sylfaen"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-sylfaen%2BSylfaen.png"
  >
</p>

- `microsoftPackages.symbol` -
  [Symbol](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Symbol"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-symbol%2BSymbol.png"
  >
</p>

- `microsoftPackages.tahoma` -
  [Tahoma](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Tahoma Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-tahoma%2BTahoma%20Regular.png"
  >
  <br>
  <sub>Tahoma Regular</sub>
  <br>
  <img
    alt="Tahoma Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-tahoma%2BTahoma%20Bold.png"
  >
  <br>
  <sub>Tahoma Bold</sub>
  <br>
</p>

- `microsoftPackages.times-new-roman` -
  [Times New Roman](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Times New Roman Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-times-new-roman%2BTimes%20New%20Roman%20Regular.png"
  >
  <br>
  <sub>Times New Roman Regular</sub>
  <br>
  <img
    alt="Times New Roman Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-times-new-roman%2BTimes%20New%20Roman%20Italic.png"
  >
  <br>
  <sub>Times New Roman Italic</sub>
  <br>
  <img
    alt="Times New Roman Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-times-new-roman%2BTimes%20New%20Roman%20Bold.png"
  >
  <br>
  <sub>Times New Roman Bold</sub>
  <br>
  <img
    alt="Times New Roman Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-times-new-roman%2BTimes%20New%20Roman%20Bold%20Italic.png"
  >
  <br>
  <sub>Times New Roman Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.trebuchet-ms` -
  [Trebuchet MS](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Trebuchet MS Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-trebuchet-ms%2BTrebuchet%20MS%20Regular.png"
  >
  <br>
  <sub>Trebuchet MS Regular</sub>
  <br>
  <img
    alt="Trebuchet MS Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-trebuchet-ms%2BTrebuchet%20MS%20Italic.png"
  >
  <br>
  <sub>Trebuchet MS Italic</sub>
  <br>
  <img
    alt="Trebuchet MS Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-trebuchet-ms%2BTrebuchet%20MS%20Bold.png"
  >
  <br>
  <sub>Trebuchet MS Bold</sub>
  <br>
  <img
    alt="Trebuchet MS Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-trebuchet-ms%2BTrebuchet%20MS%20Bold%20Italic.png"
  >
  <br>
  <sub>Trebuchet MS Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.verdana` -
  [Verdana](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Verdana Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-verdana%2BVerdana%20Regular.png"
  >
  <br>
  <sub>Verdana Regular</sub>
  <br>
  <img
    alt="Verdana Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-verdana%2BVerdana%20Italic.png"
  >
  <br>
  <sub>Verdana Italic</sub>
  <br>
  <img
    alt="Verdana Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-verdana%2BVerdana%20Bold.png"
  >
  <br>
  <sub>Verdana Bold</sub>
  <br>
  <img
    alt="Verdana Bold Italic"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-verdana%2BVerdana%20Bold%20Italic.png"
  >
  <br>
  <sub>Verdana Bold Italic</sub>
  <br>
</p>

- `microsoftPackages.webdings` -
  [Webdings](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Webdings"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-webdings%2BWebdings.png"
  >
</p>

- `microsoftPackages.wingdings` -
  [Wingdings](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Wingdings"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-wingdings%2BWingdings.png"
  >
</p>

- `microsoftPackages.yu-gothic` -
  [Yu Gothic / Yu Gothic UI](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

<p align="center">
  <img
    alt="Yu Gothic Light"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-yu-gothic%2BYu%20Gothic%20Light.png"
  >
  <br>
  <sub>Yu Gothic Light</sub>
  <br>
  <img
    alt="Yu Gothic Regular"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-yu-gothic%2BYu%20Gothic%20Regular.png"
  >
  <br>
  <sub>Yu Gothic Regular</sub>
  <br>
  <img
    alt="Yu Gothic Medium"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-yu-gothic%2BYu%20Gothic%20Medium.png"
  >
  <br>
  <sub>Yu Gothic Medium</sub>
  <br>
  <img
    alt="Yu Gothic Bold"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/microsoft/microsoft-yu-gothic%2BYu%20Gothic%20Bold.png"
  >
  <br>
  <sub>Yu Gothic Bold</sub>
  <br>
</p>

### Taobao 字体（淘宝字体）- `taobaoPackages`

Taobao 字体均可以免费用于合法的商业、非商业使用。

> [!TIP]
>
> 通过 `taobao-fonts` 来安装所有 Taobao 字体。

- `taobaoPackages.maicaiti` -
  [淘宝买菜体](https://www.alibabafonts.com/#/more)，允许嵌入式使用

<p align="center">
  <img
    alt="TBMCYXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/taobao/taobao-maicaiti%2BTBMCYXT.png"
  >
</p>

### TianHeng 字体（TH/天珩字库）- `tianhengPackages`

> [!CAUTION]
>
> 天珩字库中字体的字形来自中易、华康、Iwata、Besta、方正等公司，其字体使用必须用于非盈利、学习研究的用途。[^3]
>
> 其具体的版权问题比较复杂，建议仅做本地屏显补字用途。

> [!TIP]
>
> 通过 `tianheng-fonts` 来安装所有 TianHeng 字体。

- `tianhengPackages.hak` -
  [天珩字库-黑体](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Hak"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-hak%2BTH-Hak.png"
  >
</p>

- `tianhengPackages.joeng` -
  [天珩字库-阳明](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Joeng-H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-joeng%2BTH-Joeng-H.png"
  >
</p>

- `tianhengPackages.khaai-p` -
  [天珩字库-标楷](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Khaai-PP0"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-khaai-p%2BTH-Khaai-PP0.png"
  >
  <br>
  <sub>TH-Khaai-PP0</sub>
  <br>
  <img
    alt="TH-Khaai-PP2"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-khaai-p%2BTH-Khaai-PP2.png"
  >
  <br>
  <sub>TH-Khaai-PP2</sub>
  <br>
</p>

- `tianhengPackages.khaai-t` -
  [天珩字库-正楷](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Khaai-TP0"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-khaai-t%2BTH-Khaai-TP0.png"
  >
  <br>
  <sub>TH-Khaai-TP0</sub>
  <br>
  <img
    alt="TH-Khaai-TP2"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-khaai-t%2BTH-Khaai-TP2.png"
  >
  <br>
  <sub>TH-Khaai-TP2</sub>
  <br>
  <img
    alt="TH-Khaai-TP16"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-khaai-t%2BTH-Khaai-TP16.png"
  >
  <br>
  <sub>TH-Khaai-TP16</sub>
  <br>
</p>

- `tianhengPackages.ming` -
  [天珩字库-花园](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Ming-JP0"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-ming%2BTH-Ming-JP0.png"
  >
  <br>
  <sub>TH-Ming-JP0</sub>
  <br>
  <img
    alt="TH-Ming-JP2"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-ming%2BTH-Ming-JP2.png"
  >
  <br>
  <sub>TH-Ming-JP2</sub>
  <br>
</p>

- `tianhengPackages.sung-p` -
  [天珩字库-正宋](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Sung-PP0"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-sung-p%2BTH-Sung-PP0.png"
  >
  <br>
  <sub>TH-Sung-PP0</sub>
  <br>
  <img
    alt="TH-Sung-PP2"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-sung-p%2BTH-Sung-PP2.png"
  >
  <br>
  <sub>TH-Sung-PP2</sub>
  <br>
</p>

- `tianhengPackages.sung-t` -
  [天珩字库-标宋](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Sung-TP0"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-sung-t%2BTH-Sung-TP0.png"
  >
  <br>
  <sub>TH-Sung-TP0</sub>
  <br>
  <img
    alt="TH-Sung-TP2"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-sung-t%2BTH-Sung-TP2.png"
  >
  <br>
  <sub>TH-Sung-TP2</sub>
  <br>
</p>

- `tianhengPackages.sy` -
  [天珩字库-书宋](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Sy-P0"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-sy%2BTH-Sy-P0.png"
  >
  <br>
  <sub>TH-Sy-P0</sub>
  <br>
  <img
    alt="TH-Sy-P2"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-sy%2BTH-Sy-P2.png"
  >
  <br>
  <sub>TH-Sy-P2</sub>
  <br>
  <img
    alt="TH-Sy-P16"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-sy%2BTH-Sy-P16.png"
  >
  <br>
  <sub>TH-Sy-P16</sub>
  <br>
</p>

- `tianhengPackages.tshyn` -
  [天珩全字库](http://cheonhyeong.com/Simplified/download.html)

<p align="center">
  <img
    alt="TH-Tshyn-P0"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-tshyn%2BTH-Tshyn-P0.png"
  >
  <br>
  <sub>TH-Tshyn-P0</sub>
  <br>
  <img
    alt="TH-Tshyn-P1"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-tshyn%2BTH-Tshyn-P1.png"
  >
  <br>
  <sub>TH-Tshyn-P1</sub>
  <br>
  <img
    alt="TH-Tshyn-P2"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-tshyn%2BTH-Tshyn-P2.png"
  >
  <br>
  <sub>TH-Tshyn-P2</sub>
  <br>
  <img
    alt="TH-Tshyn-P16"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-tshyn%2BTH-Tshyn-P16.png"
  >
  <br>
  <sub>TH-Tshyn-P16</sub>
  <br>
  <img
    alt="TH-Times"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tianheng/tianheng-tshyn%2BTH-Times.png"
  >
  <br>
  <sub>TH-Times</sub>
  <br>
</p>

### TrionesType 字体（璇璣造字）- `trionestypePackages`

> [!TIP]
>
> 通过 `trionestype-fonts` 来安装所有 TrionesType 字体。

- `trionestypePackages.zhuque-fangsong` -
  [朱雀仿宋](https://github.com/TrionesType/zhuque)

<p align="center">
  <img
    alt="Zhuque Fangsong (technical preview)"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/trionestype/trionestype-zhuque-fangsong%2BZhuque%20Fangsong%20%28technical%20preview%29.png"
  >
</p>

### TsangerType 字体（仓耳字库）- `tsangertypePackages`

TsangerType 的所有字体均允许个人非商业用途使用。

> [!TIP]
>
> 通过 `tsangertype-fonts` 安装所有 TsangerType 字体。

#### 商用免费字体

> [!TIP]
>
> 通过 `tsangertype-gcu-fonts` 安装所有 TsangerType 的商用免费字体。

- `tsangertypePackages.tsangerfeibai` -
  [仓耳非白w01](https://tsanger.cn/product/206)、[w02](https://tsanger.cn/product/207)、[w03](https://tsanger.cn/product/208)、[w04](https://tsanger.cn/product/209)、[w05](https://tsanger.cn/product/210)

<p align="center">
  <img
    alt="TsangerFeiBai W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W01.png"
  >
  <br>
  <sub>TsangerFeiBai W01</sub>
  <br>
  <img
    alt="TsangerFeiBai W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W02.png"
  >
  <br>
  <sub>TsangerFeiBai W02</sub>
  <br>
  <img
    alt="TsangerFeiBai W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W03.png"
  >
  <br>
  <sub>TsangerFeiBai W03</sub>
  <br>
  <img
    alt="TsangerFeiBai W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W04.png"
  >
  <br>
  <sub>TsangerFeiBai W04</sub>
  <br>
  <img
    alt="TsangerFeiBai W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W05.png"
  >
  <br>
  <sub>TsangerFeiBai W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangershuyuant` -
  [仓耳舒圆体w01](https://tsanger.cn/product/201)、[w02](https://tsanger.cn/product/202)、[w03](https://tsanger.cn/product/203)、[w04](https://tsanger.cn/product/204)、[w05](https://tsanger.cn/product/205)

<p align="center">
  <img
    alt="TsangerShuYuanT W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W01.png"
  >
  <br>
  <sub>TsangerShuYuanT W01</sub>
  <br>
  <img
    alt="TsangerShuYuanT W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W02.png"
  >
  <br>
  <sub>TsangerShuYuanT W02</sub>
  <br>
  <img
    alt="TsangerShuYuanT W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W03.png"
  >
  <br>
  <sub>TsangerShuYuanT W03</sub>
  <br>
  <img
    alt="TsangerShuYuanT W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W04.png"
  >
  <br>
  <sub>TsangerShuYuanT W04</sub>
  <br>
  <img
    alt="TsangerShuYuanT W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W05.png"
  >
  <br>
  <sub>TsangerShuYuanT W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerzhoukezhengdabangshu` -
  [仓耳周珂正大榜书](https://tsanger.cn/product/194)

<p align="center">
  <img
    alt="TsangerZhoukeZhengdabangshu"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzhoukezhengdabangshu%2BTsangerZhoukeZhengdabangshu.png"
  >
</p>

- `tsangertypePackages.tsangerxwz` - [仓耳小丸子](https://tsanger.cn/product/195)

<p align="center">
  <img
    alt="TsangerXWZ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxwz%2BTsangerXWZ.png"
  >
</p>

- `tsangertypePackages.tsangeryumo` -
  [仓耳与墨w01](https://tsanger.cn/product/189)、[w02](https://tsanger.cn/product/190)、[w03](https://tsanger.cn/product/191)、[w04](https://tsanger.cn/product/192)、[w05](https://tsanger.cn/product/193)

<p align="center">
  <img
    alt="TsangerYuMo W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W01.png"
  >
  <br>
  <sub>TsangerYuMo W01</sub>
  <br>
  <img
    alt="TsangerYuMo W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W02.png"
  >
  <br>
  <sub>TsangerYuMo W02</sub>
  <br>
  <img
    alt="TsangerYuMo W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W03.png"
  >
  <br>
  <sub>TsangerYuMo W03</sub>
  <br>
  <img
    alt="TsangerYuMo W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W04.png"
  >
  <br>
  <sub>TsangerYuMo W04</sub>
  <br>
  <img
    alt="TsangerYuMo W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W05.png"
  >
  <br>
  <sub>TsangerYuMo W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangeryuyangt` -
  [仓耳渔阳体w01](https://tsanger.cn/product/196)、[w02](https://tsanger.cn/product/197)、[w03](https://tsanger.cn/product/198)、[w04](https://tsanger.cn/product/199)、[w05](https://tsanger.cn/product/200)

<p align="center">
  <img
    alt="TsangerYuYangT W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W01.png"
  >
  <br>
  <sub>TsangerYuYangT W01</sub>
  <br>
  <img
    alt="TsangerYuYangT W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W02.png"
  >
  <br>
  <sub>TsangerYuYangT W02</sub>
  <br>
  <img
    alt="TsangerYuYangT W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W03.png"
  >
  <br>
  <sub>TsangerYuYangT W03</sub>
  <br>
  <img
    alt="TsangerYuYangT W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W04.png"
  >
  <br>
  <sub>TsangerYuYangT W04</sub>
  <br>
  <img
    alt="TsangerYuYangT W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W05.png"
  >
  <br>
  <sub>TsangerYuYangT W05</sub>
  <br>
</p>

> [!TIP]
>
> 根据《仓耳字库免费开源字体授权声明》[^4]的描述，上述字体允许保留原始许可的前提下进行非销售用途的再分发，所以您可以从本地 store
> 复制字体向他人传播或上传到 substituter server。

#### 个人免费字体

> [!TIP]
>
> 通过 `tsangertype-gpu-fonts` 安装所有 TsangerType 的个人免费字体（包括商用免费字体）。

- `tsangertypePackages.tsangeradkkt` - [仓耳爱的坤坤体](https://tsanger.cn/product/226)

<p align="center">
  <img
    alt="TsangerADKKT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeradkkt%2BTsangerADKKT.png"
  >
</p>

- `tsangertypePackages.tsangeramxk` - [仓耳爱民小楷](https://tsanger.cn/product/108)

<p align="center">
  <img
    alt="TsangerAMXK"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeramxk%2BTsangerAMXK.png"
  >
</p>

- `tsangertypePackages.tsangeramxingkai` -
  [仓耳爱民行楷](https://tsanger.cn/product/370)

<p align="center">
  <img
    alt="TsangerAMXingKai"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeramxingkai%2BTsangerAMXingKai.png"
  >
</p>

- `tsangertypePackages.tsangeramxs` - [仓耳爱民行书](https://tsanger.cn/product/109)

<p align="center">
  <img
    alt="TsangerAMXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeramxs%2BTsangerAMXS.png"
  >
</p>

- `tsangertypePackages.tsangeranmmdt` -
  [仓耳爱你萌萌哒](https://tsanger.cn/product/373)

<p align="center">
  <img
    alt="TsangerANMMDT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeranmmdt%2BTsangerANMMDT.png"
  >
</p>

- `tsangertypePackages.tsangeraqlxs` - [仓耳爱情练习生](https://tsanger.cn/product/107)

<p align="center">
  <img
    alt="TsangerAQLXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeraqlxs%2BTsangerAQLXS.png"
  >
</p>

- `tsangertypePackages.tsangerbanghei` - [仓耳榜黑](https://tsanger.cn/product/387)

<p align="center">
  <img
    alt="TsangerBangHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerbanghei%2BTsangerBangHei.png"
  >
</p>

- `tsangertypePackages.tsangerbblt` - [仓耳吧吡咙体](https://tsanger.cn/product/255)

<p align="center">
  <img
    alt="TsangerBBLT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerbblt%2BTsangerBBLT.png"
  >
</p>

- `tsangertypePackages.tsangerblgl` -
  [仓耳百灵w01](https://tsanger.cn/product/211)、[w02](https://tsanger.cn/product/212)、[w03](https://tsanger.cn/product/213)、[w04](https://tsanger.cn/product/214)、[w05](https://tsanger.cn/product/215)

<p align="center">
  <img
    alt="TsangerBL-GL W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerblgl%2BTsangerBL-GL%20W01.png"
  >
  <br>
  <sub>TsangerBL-GL W01</sub>
  <br>
  <img
    alt="TsangerBL-GL W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerblgl%2BTsangerBL-GL%20W02.png"
  >
  <br>
  <sub>TsangerBL-GL W02</sub>
  <br>
  <img
    alt="TsangerBL-GL W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerblgl%2BTsangerBL-GL%20W03.png"
  >
  <br>
  <sub>TsangerBL-GL W03</sub>
  <br>
  <img
    alt="TsangerBL-GL W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerblgl%2BTsangerBL-GL%20W04.png"
  >
  <br>
  <sub>TsangerBL-GL W04</sub>
  <br>
  <img
    alt="TsangerBL-GL W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerblgl%2BTsangerBL-GL%20W05.png"
  >
  <br>
  <sub>TsangerBL-GL W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerbmzct` - [仓耳本喵在此体](https://tsanger.cn/product/228)

<p align="center">
  <img
    alt="TsangerBMZCT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerbmzct%2BTsangerBMZCT.png"
  >
</p>

- `tsangertypePackages.tsangerbtsz` - [仓耳半糖手札](https://tsanger.cn/product/328)

<p align="center">
  <img
    alt="TsangerBTSZ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerbtsz%2BTsangerBTSZ.png"
  >
</p>

- `tsangertypePackages.tsangercllsj` - [仓耳曹录林手迹](https://tsanger.cn/product/256)

<p align="center">
  <img
    alt="TsangerCLLSJ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangercllsj%2BTsangerCLLSJ.png"
  >
</p>

- `tsangertypePackages.tsangercsskdfxt` -
  [城市上空的繁星体](https://tsanger.cn/product/252)

<p align="center">
  <img
    alt="TsangerCSSKDFXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangercsskdfxt%2BTsangerCSSKDFXT.png"
  >
</p>

- `tsangertypePackages.tsangerchuangyi` -
  [仓耳创意体w01](https://tsanger.cn/product/56)、[w02](https://tsanger.cn/product/57)、[w03](https://tsanger.cn/product/58)

<p align="center">
  <img
    alt="TsangerChuangYi-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerchuangyi%2BTsangerChuangYi-W01.png"
  >
  <br>
  <sub>TsangerChuangYi-W01</sub>
  <br>
  <img
    alt="TsangerChuangYi-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerchuangyi%2BTsangerChuangYi-W02.png"
  >
  <br>
  <sub>TsangerChuangYi-W02</sub>
  <br>
  <img
    alt="TsangerChuangYi-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerchuangyi%2BTsangerChuangYi-W03.png"
  >
  <br>
  <sub>TsangerChuangYi-W03</sub>
  <br>
</p>

- `tsangertypePackages.tsangerchunfeng` - [仓耳春风体](https://tsanger.cn/product/17)

<p align="center">
  <img
    alt="TsangerChunFeng-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerchunfeng%2BTsangerChunFeng-W04.png"
  >
</p>

- `tsangertypePackages.tsangerczbjxks` -
  [仓耳曹哲斌俊秀楷书](https://tsanger.cn/product/216)、[加粗](https://tsanger.cn/product/92)

<p align="center">
  <img
    alt="TsangerCZBJXKS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerczbjxks%2BTsangerCZBJXKS.png"
  >
  <br>
  <sub>TsangerCZBJXKS</sub>
  <br>
  <img
    alt="TsangerCZBJXKSJC"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerczbjxks%2BTsangerCZBJXKSJC.png"
  >
  <br>
  <sub>TsangerCZBJXKSJC</sub>
  <br>
</p>

- `tsangertypePackages.tsangerczbksjf` -
  [仓耳曹哲斌楷书](https://tsanger.cn/product/93)、[加粗](https://tsanger.cn/product/94)

<p align="center">
  <img
    alt="TsangerCZBKSJC"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerczbksjf%2BTsangerCZBKSJC.png"
  >
  <br>
  <sub>TsangerCZBKSJC</sub>
  <br>
  <img
    alt="TsangerCZBKSJF"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerczbksjf%2BTsangerCZBKSJF.png"
  >
  <br>
  <sub>TsangerCZBKSJF</sub>
  <br>
</p>

- `tsangertypePackages.tsangerczblyks` -
  [仓耳曹哲斌灵韵楷书](https://tsanger.cn/product/217)、[加粗](https://tsanger.cn/product/95)

<p align="center">
  <img
    alt="TsangerCZBLYKS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerczblyks%2BTsangerCZBLYKS.png"
  >
  <br>
  <sub>TsangerCZBLYKS</sub>
  <br>
  <img
    alt="TsangerCZBLYKSJC"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerczblyks%2BTsangerCZBLYKSJC.png"
  >
  <br>
  <sub>TsangerCZBLYKSJC</sub>
  <br>
</p>

- `tsangertypePackages.tsangerczbxkjf` -
  [仓耳曹哲斌行楷](https://tsanger.cn/product/96)

<p align="center">
  <img
    alt="TsangerCZBXKJF"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerczbxkjf%2BTsangerCZBXKJF.png"
  >
</p>

- `tsangertypePackages.tsangercyt` - [仓耳初遇体](https://tsanger.cn/product/257)

<p align="center">
  <img
    alt="TsangerCYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangercyt%2BTsangerCYT.png"
  >
</p>

- `tsangertypePackages.tsangerdajiti` - [仓耳大吉体](https://tsanger.cn/product/258)

<p align="center">
  <img
    alt="TsangerDaJiTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdajiti%2BTsangerDaJiTi.png"
  >
</p>

- `tsangertypePackages.tsangerdmmt` -
  [仓耳大漫漫体w01](https://tsanger.cn/product/21)、[w02](https://tsanger.cn/product/22)、[w03](https://tsanger.cn/product/23)、[w04](https://tsanger.cn/product/24)、[w05](https://tsanger.cn/product/25)

<p align="center">
  <img
    alt="TsangerDMMT W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdmmt%2BTsangerDMMT%20W01.png"
  >
  <br>
  <sub>TsangerDMMT W01</sub>
  <br>
  <img
    alt="TsangerDMMT W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdmmt%2BTsangerDMMT%20W02.png"
  >
  <br>
  <sub>TsangerDMMT W02</sub>
  <br>
  <img
    alt="TsangerDMMT W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdmmt%2BTsangerDMMT%20W03.png"
  >
  <br>
  <sub>TsangerDMMT W03</sub>
  <br>
  <img
    alt="TsangerDMMT W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdmmt%2BTsangerDMMT%20W04.png"
  >
  <br>
  <sub>TsangerDMMT W04</sub>
  <br>
  <img
    alt="TsangerDMMT W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdmmt%2BTsangerDMMT%20W05.png"
  >
  <br>
  <sub>TsangerDMMT W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerdmxmtt` -
  [仓耳呆萌小木头体](https://tsanger.cn/product/229)

<p align="center">
  <img
    alt="TsangerDMXMTT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdmxmtt%2BTsangerDMXMTT.png"
  >
</p>

- `tsangertypePackages.tsangerdnsxt` - [呆牛手写体](https://tsanger.cn/product/319)

<p align="center">
  <img
    alt="TsangerDNSXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdnsxt%2BTsangerDNSXT.png"
  >
</p>

- `tsangertypePackages.tsangerdfzst` - 刀锋战士体、粗体\*

<p align="center">
  <img
    alt="TsangerDFZSCT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdfzst%2BTsangerDFZSCT.png"
  >
  <br>
  <sub>TsangerDFZSCT</sub>
  <br>
  <img
    alt="TsangerDFZST"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdfzst%2BTsangerDFZST.png"
  >
  <br>
  <sub>TsangerDFZST</sub>
  <br>
</p>

- `tsangertypePackages.tsangerdscjt` - [仓耳点石成金体](https://tsanger.cn/product/106)

<p align="center">
  <img
    alt="TsangerDSCJT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdscjt%2BTsangerDSCJT.png"
  >
</p>

- `tsangertypePackages.tsangerdubaiti` - [仓耳独白体](https://tsanger.cn/product/261)

<p align="center">
  <img
    alt="TsangerDUBAITI"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdubaiti%2BTsangerDUBAITI.png"
  >
</p>

- `tsangertypePackages.tsangerddt` -
  [仓耳嘟嘟体w01](https://tsanger.cn/product/62)、[w02](https://tsanger.cn/product/63)、[w03](https://tsanger.cn/product/64)、[w04](https://tsanger.cn/product/65)

<p align="center">
  <img
    alt="TsangerDDT-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerddt%2BTsangerDDT-W01.png"
  >
  <br>
  <sub>TsangerDDT-W01</sub>
  <br>
  <img
    alt="TsangerDDT-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerddt%2BTsangerDDT-W02.png"
  >
  <br>
  <sub>TsangerDDT-W02</sub>
  <br>
  <img
    alt="TsangerDDT-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerddt%2BTsangerDDT-W03.png"
  >
  <br>
  <sub>TsangerDDT-W03</sub>
  <br>
  <img
    alt="TsangerDDT-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerddt%2BTsangerDDT-W04.png"
  >
  <br>
  <sub>TsangerDDT-W04</sub>
  <br>
</p>

- `tsangertypePackages.tsangerdwt` - [仓耳蝶舞体](https://tsanger.cn/product/260)

<p align="center">
  <img
    alt="TsangerDWT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerdwt%2BTsangerDWT.png"
  >
</p>

- `tsangertypePackages.tsangerfeibai` -
  [仓耳非白w01](https://tsanger.cn/product/206)、[w02](https://tsanger.cn/product/207)、[w03](https://tsanger.cn/product/208)、[w04](https://tsanger.cn/product/209)、[w05](https://tsanger.cn/product/210)

<p align="center">
  <img
    alt="TsangerFeiBai W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W01.png"
  >
  <br>
  <sub>TsangerFeiBai W01</sub>
  <br>
  <img
    alt="TsangerFeiBai W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W02.png"
  >
  <br>
  <sub>TsangerFeiBai W02</sub>
  <br>
  <img
    alt="TsangerFeiBai W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W03.png"
  >
  <br>
  <sub>TsangerFeiBai W03</sub>
  <br>
  <img
    alt="TsangerFeiBai W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W04.png"
  >
  <br>
  <sub>TsangerFeiBai W04</sub>
  <br>
  <img
    alt="TsangerFeiBai W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfeibai%2BTsangerFeiBai%20W05.png"
  >
  <br>
  <sub>TsangerFeiBai W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangermxt` - [仓耳木兮体](https://tsanger.cn/product/282)

<p align="center">
  <img
    alt="TsangerMXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermxt%2BTsangerMXT.png"
  >
</p>

- `tsangertypePackages.tsangersangqi` -
  [仓耳第一眼爱上你](https://tsanger.cn/product/259)

<p align="center">
  <img
    alt="仓耳第一眼爱上你"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersangqi%2B%E4%BB%93%E8%80%B3%E7%AC%AC%E4%B8%80%E7%9C%BC%E7%88%B1%E4%B8%8A%E4%BD%A0.png"
  >
</p>

- `tsangertypePackages.tsangershuyuant` -
  [仓耳舒圆体w01](https://tsanger.cn/product/201)、[w02](https://tsanger.cn/product/202)、[w03](https://tsanger.cn/product/203)、[w04](https://tsanger.cn/product/204)、[w05](https://tsanger.cn/product/205)

<p align="center">
  <img
    alt="TsangerShuYuanT W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W01.png"
  >
  <br>
  <sub>TsangerShuYuanT W01</sub>
  <br>
  <img
    alt="TsangerShuYuanT W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W02.png"
  >
  <br>
  <sub>TsangerShuYuanT W02</sub>
  <br>
  <img
    alt="TsangerShuYuanT W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W03.png"
  >
  <br>
  <sub>TsangerShuYuanT W03</sub>
  <br>
  <img
    alt="TsangerShuYuanT W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W04.png"
  >
  <br>
  <sub>TsangerShuYuanT W04</sub>
  <br>
  <img
    alt="TsangerShuYuanT W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuyuant%2BTsangerShuYuanT%20W05.png"
  >
  <br>
  <sub>TsangerShuYuanT W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerzhoukezhengdabangshu` -
  [仓耳周珂正大榜书](https://tsanger.cn/product/194)

<p align="center">
  <img
    alt="TsangerZhoukeZhengdabangshu"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzhoukezhengdabangshu%2BTsangerZhoukeZhengdabangshu.png"
  >
</p>

- `tsangertypePackages.tsangerxwz` - [仓耳小丸子](https://tsanger.cn/product/195)

<p align="center">
  <img
    alt="TsangerXWZ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxwz%2BTsangerXWZ.png"
  >
</p>

- `tsangertypePackages.tsangeryumo` -
  [仓耳与墨w01](https://tsanger.cn/product/189)、[w02](https://tsanger.cn/product/190)、[w03](https://tsanger.cn/product/191)、[w04](https://tsanger.cn/product/192)、[w05](https://tsanger.cn/product/193)

<p align="center">
  <img
    alt="TsangerYuMo W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W01.png"
  >
  <br>
  <sub>TsangerYuMo W01</sub>
  <br>
  <img
    alt="TsangerYuMo W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W02.png"
  >
  <br>
  <sub>TsangerYuMo W02</sub>
  <br>
  <img
    alt="TsangerYuMo W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W03.png"
  >
  <br>
  <sub>TsangerYuMo W03</sub>
  <br>
  <img
    alt="TsangerYuMo W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W04.png"
  >
  <br>
  <sub>TsangerYuMo W04</sub>
  <br>
  <img
    alt="TsangerYuMo W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryumo%2BTsangerYuMo%20W05.png"
  >
  <br>
  <sub>TsangerYuMo W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangeryuyangt` -
  [仓耳渔阳体w01](https://tsanger.cn/product/196)、[w02](https://tsanger.cn/product/197)、[w03](https://tsanger.cn/product/198)、[w04](https://tsanger.cn/product/199)、[w05](https://tsanger.cn/product/200)

<p align="center">
  <img
    alt="TsangerYuYangT W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W01.png"
  >
  <br>
  <sub>TsangerYuYangT W01</sub>
  <br>
  <img
    alt="TsangerYuYangT W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W02.png"
  >
  <br>
  <sub>TsangerYuYangT W02</sub>
  <br>
  <img
    alt="TsangerYuYangT W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W03.png"
  >
  <br>
  <sub>TsangerYuYangT W03</sub>
  <br>
  <img
    alt="TsangerYuYangT W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W04.png"
  >
  <br>
  <sub>TsangerYuYangT W04</sub>
  <br>
  <img
    alt="TsangerYuYangT W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuyangt%2BTsangerYuYangT%20W05.png"
  >
  <br>
  <sub>TsangerYuYangT W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerfanghei` - [仓耳方黑](https://tsanger.cn/product/386)

<p align="center">
  <img
    alt="TsangerFanghei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfanghei%2BTsangerFanghei.png"
  >
</p>

- `tsangertypePackages.tsangerfft` -
  [仓耳飞飞体w01](https://tsanger.cn/product/162)、[w02](https://tsanger.cn/product/163)、[w03](https://tsanger.cn/product/164)、[w04](https://tsanger.cn/product/165)

<p align="center">
  <img
    alt="TsangerFFT-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfft%2BTsangerFFT-W01.png"
  >
  <br>
  <sub>TsangerFFT-W01</sub>
  <br>
  <img
    alt="TsangerFFT-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfft%2BTsangerFFT-W02.png"
  >
  <br>
  <sub>TsangerFFT-W02</sub>
  <br>
  <img
    alt="TsangerFFT-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfft%2BTsangerFFT-W03.png"
  >
  <br>
  <sub>TsangerFFT-W03</sub>
  <br>
  <img
    alt="TsangerFFT-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfft%2BTsangerFFT-W04.png"
  >
  <br>
  <sub>TsangerFFT-W04</sub>
  <br>
</p>

- `tsangertypePackages.tsangerftt` - [仓耳沸腾体](https://tsanger.cn/product/262)

<p align="center">
  <img
    alt="TsangerFTT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerftt%2BTsangerFTT.png"
  >
</p>

- `tsangertypePackages.tsangerfec` - [仓耳风儿吹](https://tsanger.cn/product/231)

<p align="center">
  <img
    alt="TsangerFEC"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfec%2BTsangerFEC.png"
  >
</p>

- `tsangertypePackages.tsangerfenghei` - [仓耳丰黑](https://tsanger.cn/product/381)

<p align="center">
  <img
    alt="TsangerFengHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfenghei%2BTsangerFengHei.png"
  >
</p>

- `tsangertypePackages.tsangerfwjt` -
  [仓耳锋舞九天w01](https://tsanger.cn/product/143)、[w02](https://tsanger.cn/product/144)、[w03](https://tsanger.cn/product/145)、[w04](https://tsanger.cn/product/146)、[w05](https://tsanger.cn/product/147)、[w06](https://tsanger.cn/product/148)

<p align="center">
  <img
    alt="TsangerFWJT-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfwjt%2BTsangerFWJT-W01.png"
  >
  <br>
  <sub>TsangerFWJT-W01</sub>
  <br>
  <img
    alt="TsangerFWJT-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfwjt%2BTsangerFWJT-W02.png"
  >
  <br>
  <sub>TsangerFWJT-W02</sub>
  <br>
  <img
    alt="TsangerFWJT-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfwjt%2BTsangerFWJT-W03.png"
  >
  <br>
  <sub>TsangerFWJT-W03</sub>
  <br>
  <img
    alt="TsangerFWJT-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfwjt%2BTsangerFWJT-W04.png"
  >
  <br>
  <sub>TsangerFWJT-W04</sub>
  <br>
  <img
    alt="TsangerFWJT-W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfwjt%2BTsangerFWJT-W05.png"
  >
  <br>
  <sub>TsangerFWJT-W05</sub>
  <br>
  <img
    alt="TsangerFWJT-W06"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfwjt%2BTsangerFWJT-W06.png"
  >
  <br>
  <sub>TsangerFWJT-W06</sub>
  <br>
</p>

- `tsangertypePackages.tsangerfyt` -
  [仓耳锋韵w01](https://tsanger.cn/product/149)、[w02](https://tsanger.cn/product/150)、[w03](https://tsanger.cn/product/151)、[w04](https://tsanger.cn/product/152)、[w05](https://tsanger.cn/product/153)、[w06](https://tsanger.cn/product/154)、[w07](https://tsanger.cn/product/155)

<p align="center">
  <img
    alt="TsangerFengYun-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfyt%2BTsangerFengYun-W01.png"
  >
  <br>
  <sub>TsangerFengYun-W01</sub>
  <br>
  <img
    alt="TsangerFengYun-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfyt%2BTsangerFengYun-W02.png"
  >
  <br>
  <sub>TsangerFengYun-W02</sub>
  <br>
  <img
    alt="TsangerFengYun-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfyt%2BTsangerFengYun-W03.png"
  >
  <br>
  <sub>TsangerFengYun-W03</sub>
  <br>
  <img
    alt="TsangerFengYun-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfyt%2BTsangerFengYun-W04.png"
  >
  <br>
  <sub>TsangerFengYun-W04</sub>
  <br>
  <img
    alt="TsangerFengYun-W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfyt%2BTsangerFengYun-W05.png"
  >
  <br>
  <sub>TsangerFengYun-W05</sub>
  <br>
  <img
    alt="TsangerFengYun-W06"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfyt%2BTsangerFengYun-W06.png"
  >
  <br>
  <sub>TsangerFengYun-W06</sub>
  <br>
  <img
    alt="TsangerFengYun-W07"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfyt%2BTsangerFengYun-W07.png"
  >
  <br>
  <sub>TsangerFengYun-W07</sub>
  <br>
</p>

- `tsangertypePackages.tsangergxtyt` - [仓耳个性涂鸦体](https://tsanger.cn/product/263)

<p align="center">
  <img
    alt="TsangerGXTYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangergxtyt%2BTsangerGXTYT.png"
  >
</p>

- `tsangertypePackages.tsangergtt` - [仓耳瓜藤体](https://tsanger.cn/product/232)

<p align="center">
  <img
    alt="TsangerGTT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangergtt%2BTsangerGTT.png"
  >
</p>

- `tsangertypePackages.tsangergfks` - [仓耳古风楷书](https://tsanger.cn/product/60)

<p align="center">
  <img
    alt="TsangerGFKS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangergfks%2BTsangerGFKS.png"
  >
</p>

- `tsangertypePackages.tsangergfxs` - [仓耳古风行书](https://tsanger.cn/product/61)

<p align="center">
  <img
    alt="TsangerGFXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangergfxs%2BTsangerGFXS.png"
  >
</p>

- `tsangertypePackages.tsangerguli` -
  [仓耳谷力w01](https://tsanger.cn/product/131)、[w02](https://tsanger.cn/product/132)、[w03](https://tsanger.cn/product/133)、[w04](https://tsanger.cn/product/134)、[w05](https://tsanger.cn/product/135)

<p align="center">
  <img
    alt="TsangerGuLi W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerguli%2BTsangerGuLi%20W01.png"
  >
  <br>
  <sub>TsangerGuLi W01</sub>
  <br>
  <img
    alt="TsangerGuLi W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerguli%2BTsangerGuLi%20W02.png"
  >
  <br>
  <sub>TsangerGuLi W02</sub>
  <br>
  <img
    alt="TsangerGuLi W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerguli%2BTsangerGuLi%20W03.png"
  >
  <br>
  <sub>TsangerGuLi W03</sub>
  <br>
  <img
    alt="TsangerGuLi W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerguli%2BTsangerGuLi%20W04.png"
  >
  <br>
  <sub>TsangerGuLi W04</sub>
  <br>
  <img
    alt="TsangerGuLi W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerguli%2BTsangerGuLi%20W05.png"
  >
  <br>
  <sub>TsangerGuLi W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangergdxxt` - [仓耳果冻吸吸体](https://tsanger.cn/product/265)

<p align="center">
  <img
    alt="TsangerGDXXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangergdxxt%2BTsangerGDXXT.png"
  >
</p>

- `tsangertypePackages.tsangerguyun` - [仓耳古韵体](https://tsanger.cn/product/59)

<p align="center">
  <img
    alt="TsangerGuYun-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerguyun%2BTsangerGuYun-W04.png"
  >
</p>

- `tsangertypePackages.tsangerhltxst` -
  [仓耳哈喽兔先生体](https://tsanger.cn/product/233)

<p align="center">
  <img
    alt="TsangerHLTXST"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerhltxst%2BTsangerHLTXST.png"
  >
</p>

- `tsangertypePackages.tsangerhst` - [仓耳寒山体](https://tsanger.cn/product/266)

<p align="center">
  <img
    alt="TsangerHST"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerhst%2BTsangerHST.png"
  >
</p>

- `tsangertypePackages.tsangerhft` - [仓耳荷风体](https://tsanger.cn/product/267)

<p align="center">
  <img
    alt="TsangerHFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerhft%2BTsangerHFT.png"
  >
</p>

- `tsangertypePackages.tsangerhuaxinti` -
  [仓耳华新体](https://tsanger.cn/product/396)

<p align="center">
  <img
    alt="倉耳華新體"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerhuaxinti%2B%E5%80%89%E8%80%B3%E8%8F%AF%E6%96%B0%E9%AB%94.png"
  >
</p>

- `tsangertypePackages.tsangerhby` - [仓耳花语](https://tsanger.cn/product/234)

<p align="center">
  <img
    alt="TsangerHBY"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerhby%2BTsangerHBY.png"
  >
</p>

- `tsangertypePackages.tsangerjtmqdt` -
  [仓耳焦糖玛奇朵体](https://tsanger.cn/product/269)

<p align="center">
  <img
    alt="TsangerJTMQDT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjtmqdt%2BTsangerJTMQDT.png"
  >
</p>

- `tsangertypePackages.tsangerjxt` - [仓耳佳轩体](https://tsanger.cn/product/268)

<p align="center">
  <img
    alt="TsangerJXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjxt%2BTsangerJXT.png"
  >
</p>

- `tsangertypePackages.tsangerjkt` - [仓耳结扣体](https://tsanger.cn/product/270)

<p align="center">
  <img
    alt="TsangerJKT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjkt%2BTsangerJKT.png"
  >
</p>

- `tsangertypePackages.tsangerjmt` - [仓耳芥末体](https://tsanger.cn/product/271)

<p align="center">
  <img
    alt="TsangerJMT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjmt%2BTsangerJMT.png"
  >
</p>

- `tsangertypePackages.tsangerjyt` - [仓耳静雅体](https://tsanger.cn/product/272)

<p align="center">
  <img
    alt="TsangerJYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjyt%2BTsangerJYT.png"
  >
</p>

- `tsangertypePackages.tsangerjinkai` -
  仓耳今楷01：[w01](https://tsanger.cn/product/4)、[w02](https://tsanger.cn/product/5)、[w03](https://tsanger.cn/product/6)、[w04](https://tsanger.cn/product/7)、[w05](https://tsanger.cn/product/8)；仓耳今楷02：[w01](https://tsanger.cn/product/14)、[w02](https://tsanger.cn/product/31)、[w03](https://tsanger.cn/product/32)、[w04](https://tsanger.cn/product/33)、[w05](https://tsanger.cn/product/34)；仓耳今楷03：[w01](https://tsanger.cn/product/35)、[w02](https://tsanger.cn/product/36)、[w03](https://tsanger.cn/product/37)、[w04](https://tsanger.cn/product/38)、[w05](https://tsanger.cn/product/39)；仓耳今楷04：[w01](https://tsanger.cn/product/40)、[w02](https://tsanger.cn/product/41)、[w03](https://tsanger.cn/product/42)、[w04](https://tsanger.cn/product/43)、[w05](https://tsanger.cn/product/44)；仓耳今楷05：[w01](https://tsanger.cn/product/45)、[w02](https://tsanger.cn/product/46)、[w03](https://tsanger.cn/product/47)、[w04](https://tsanger.cn/product/48)、[w05](https://tsanger.cn/product/49)；

<p align="center">
  <img
    alt="TsangerJinKai01 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai01%20W01.png"
  >
  <br>
  <sub>TsangerJinKai01 W01</sub>
  <br>
  <img
    alt="TsangerJinKai01 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai01%20W02.png"
  >
  <br>
  <sub>TsangerJinKai01 W02</sub>
  <br>
  <img
    alt="TsangerJinKai01 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai01%20W03.png"
  >
  <br>
  <sub>TsangerJinKai01 W03</sub>
  <br>
  <img
    alt="TsangerJinKai01 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai01%20W04.png"
  >
  <br>
  <sub>TsangerJinKai01 W04</sub>
  <br>
  <img
    alt="TsangerJinKai01 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai01%20W05.png"
  >
  <br>
  <sub>TsangerJinKai01 W05</sub>
  <br>
  <img
    alt="TsangerJinKai02 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai02%20W01.png"
  >
  <br>
  <sub>TsangerJinKai02 W01</sub>
  <br>
  <img
    alt="TsangerJinKai02 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai02%20W02.png"
  >
  <br>
  <sub>TsangerJinKai02 W02</sub>
  <br>
  <img
    alt="TsangerJinKai02 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai02%20W03.png"
  >
  <br>
  <sub>TsangerJinKai02 W03</sub>
  <br>
  <img
    alt="TsangerJinKai02 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai02%20W04.png"
  >
  <br>
  <sub>TsangerJinKai02 W04</sub>
  <br>
  <img
    alt="TsangerJinKai02 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai02%20W05.png"
  >
  <br>
  <sub>TsangerJinKai02 W05</sub>
  <br>
  <img
    alt="TsangerJinKai03 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai03%20W01.png"
  >
  <br>
  <sub>TsangerJinKai03 W01</sub>
  <br>
  <img
    alt="TsangerJinKai03 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai03%20W02.png"
  >
  <br>
  <sub>TsangerJinKai03 W02</sub>
  <br>
  <img
    alt="TsangerJinKai03 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai03%20W03.png"
  >
  <br>
  <sub>TsangerJinKai03 W03</sub>
  <br>
  <img
    alt="TsangerJinKai03 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai03%20W04.png"
  >
  <br>
  <sub>TsangerJinKai03 W04</sub>
  <br>
  <img
    alt="TsangerJinKai03 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai03%20W05.png"
  >
  <br>
  <sub>TsangerJinKai03 W05</sub>
  <br>
  <img
    alt="TsangerJinKai04 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai04%20W01.png"
  >
  <br>
  <sub>TsangerJinKai04 W01</sub>
  <br>
  <img
    alt="TsangerJinKai04 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai04%20W02.png"
  >
  <br>
  <sub>TsangerJinKai04 W02</sub>
  <br>
  <img
    alt="TsangerJinKai04 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai04%20W03.png"
  >
  <br>
  <sub>TsangerJinKai04 W03</sub>
  <br>
  <img
    alt="TsangerJinKai04 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai04%20W04.png"
  >
  <br>
  <sub>TsangerJinKai04 W04</sub>
  <br>
  <img
    alt="TsangerJinKai04 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai04%20W05.png"
  >
  <br>
  <sub>TsangerJinKai04 W05</sub>
  <br>
  <img
    alt="TsangerJinKai05 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai05%20W01.png"
  >
  <br>
  <sub>TsangerJinKai05 W01</sub>
  <br>
  <img
    alt="TsangerJinKai05 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai05%20W02.png"
  >
  <br>
  <sub>TsangerJinKai05 W02</sub>
  <br>
  <img
    alt="TsangerJinKai05 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai05%20W03.png"
  >
  <br>
  <sub>TsangerJinKai05 W03</sub>
  <br>
  <img
    alt="TsangerJinKai05 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai05%20W04.png"
  >
  <br>
  <sub>TsangerJinKai05 W04</sub>
  <br>
  <img
    alt="TsangerJinKai05 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjinkai%2BTsangerJinKai05%20W05.png"
  >
  <br>
  <sub>TsangerJinKai05 W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerjsryt` - [仓耳金石荣耀体](https://tsanger.cn/product/329)

<p align="center">
  <img
    alt="TsangerJSRYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjsryt%2BTsangerJSRYT.png"
  >
</p>

- `tsangertypePackages.tsangerjdks` - [仓耳俊冬楷书](https://tsanger.cn/product/356)

<p align="center">
  <img
    alt="TsangerJDKS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjdks%2BTsangerJDKS.png"
  >
</p>

- `tsangertypePackages.tsangerjdxs` - [仓耳俊冬行书](https://tsanger.cn/product/355)

<p align="center">
  <img
    alt="TsangerJDXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjdxs%2BTsangerJDXS.png"
  >
</p>

- `tsangertypePackages.tsangerjzcf` - [仓耳聚珍长仿](https://tsanger.cn/product/393)

<p align="center">
  <img
    alt="TsangerJZCF"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjzcf%2BTsangerJZCF.png"
  >
</p>

- `tsangertypePackages.tsangerjzw` - [仓耳橘子味](https://tsanger.cn/product/273)

<p align="center">
  <img
    alt="TsangerJZW"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerjzw%2BTsangerJZW.png"
  >
</p>

- `tsangertypePackages.tsangerkeketi` - [仓耳柯柯体](https://tsanger.cn/product/274)

<p align="center">
  <img
    alt="TsangerKeKeTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerkeketi%2BTsangerKeKeTi.png"
  >
</p>

- `tsangertypePackages.tsangerklks` - [仓耳孔璐楷书](https://tsanger.cn/product/365)

<p align="center">
  <img
    alt="TsangerKLKS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerklks%2BTsangerKLKS.png"
  >
</p>

- `tsangertypePackages.tsangerkuhei` - [仓耳酷黑](https://tsanger.cn/product/395)

<p align="center">
  <img
    alt="TsangerKuHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerkuhei%2BTsangerKuHei.png"
  >
</p>

- `tsangertypePackages.tsangerlankai` - [仓耳兰楷](https://tsanger.cn/product/366)

<p align="center">
  <img
    alt="TsangerLanKai"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlankai%2BTsangerLanKai.png"
  >
</p>

- `tsangertypePackages.tsangerlzhft` - [仓耳雷震汉风体](https://tsanger.cn/product/156)

<p align="center">
  <img
    alt="TsangerLZHFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlzhft%2BTsangerLZHFT.png"
  >
</p>

- `tsangertypePackages.tsangerlkkt` - [仓耳乐可可体](https://tsanger.cn/product/275)

<p align="center">
  <img
    alt="TsangerLKKT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlkkt%2BTsangerLKKT.png"
  >
</p>

- `tsangertypePackages.tsangerllbjt` - [乐乐笔记体](https://tsanger.cn/product/322)

<p align="center">
  <img
    alt="TsangerLLBJT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerllbjt%2BTsangerLLBJT.png"
  >
</p>

- `tsangertypePackages.tsangerlzt` - [仓耳乐志体](https://tsanger.cn/product/276)

<p align="center">
  <img
    alt="TsangerLZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlzt%2BTsangerLZT.png"
  >
</p>

- `tsangertypePackages.tsangerlabjt` - 仓耳恋爱笔记体\*

<p align="center">
  <img
    alt="TsangerLABJT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlabjt%2BTsangerLABJT.png"
  >
</p>

- `tsangertypePackages.tsangerlifeiti` - [仓耳利飞体](https://tsanger.cn/product/371)

<p align="center">
  <img
    alt="TsangerLiFeiTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlifeiti%2BTsangerLiFeiTi.png"
  >
</p>

- `tsangertypePackages.tsangerlinggang` -
  [仓耳凌刚体w01](https://tsanger.cn/product/51)、[w02](https://tsanger.cn/product/52)、[w03](https://tsanger.cn/product/53)、[w04](https://tsanger.cn/product/54)、[w05](https://tsanger.cn/product/55)

<p align="center">
  <img
    alt="TsangerLingGang-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlinggang%2BTsangerLingGang-W03.png"
  >
  <br>
  <sub>TsangerLingGang-W03</sub>
  <br>
  <img
    alt="TsangerLingGang-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlinggang%2BTsangerLingGang-W04.png"
  >
  <br>
  <sub>TsangerLingGang-W04</sub>
  <br>
  <img
    alt="TsangerLingGang-W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlinggang%2BTsangerLingGang-W05.png"
  >
  <br>
  <sub>TsangerLingGang-W05</sub>
  <br>
  <img
    alt="仓耳凌刚体W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlinggang%2B%E4%BB%93%E8%80%B3%E5%87%8C%E5%88%9A%E4%BD%93W01.png"
  >
  <br>
  <sub>仓耳凌刚体W01</sub>
  <br>
  <img
    alt="仓耳凌刚体W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlinggang%2B%E4%BB%93%E8%80%B3%E5%87%8C%E5%88%9A%E4%BD%93W02.png"
  >
  <br>
  <sub>仓耳凌刚体W02</sub>
  <br>
</p>

- `tsangertypePackages.tsangerlyt` - [仓耳凌云体](https://tsanger.cn/product/277)

<p align="center">
  <img
    alt="TsangerLYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlyt%2BTsangerLYT.png"
  >
</p>

- `tsangertypePackages.tsangerlishiti` - [仓耳力士体](https://tsanger.cn/product/363)

<p align="center">
  <img
    alt="TsangerLiShiTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerlishiti%2BTsangerLiShiTi.png"
  >
</p>

- `tsangertypePackages.tsangerliyuan` - [仓耳丽圆](https://tsanger.cn/product/390)

<p align="center">
  <img
    alt="TsangerLiyuan"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerliyuan%2BTsangerLiyuan.png"
  >
</p>

- `tsangertypePackages.tsangermanmiao` - [仓耳曼妙体](https://tsanger.cn/product/98)

<p align="center">
  <img
    alt="TsangerManMiao"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermanmiao%2BTsangerManMiao.png"
  >
</p>

- `tsangertypePackages.tsangermbht` - [仓耳猫薄荷体](https://tsanger.cn/product/278)

<p align="center">
  <img
    alt="TsangerMBHT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermbht%2BTsangerMBHT.png"
  >
</p>

- `tsangertypePackages.tsangermeixin` -
  [仓耳美心体w01](https://tsanger.cn/product/123)、[w02](https://tsanger.cn/product/124)

<p align="center">
  <img
    alt="TsangerMeiXin-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermeixin%2BTsangerMeiXin-W01.png"
  >
  <br>
  <sub>TsangerMeiXin-W01</sub>
  <br>
  <img
    alt="TsangerMeiXin-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermeixin%2BTsangerMeiXin-W02.png"
  >
  <br>
  <sub>TsangerMeiXin-W02</sub>
  <br>
</p>

- `tsangertypePackages.tsangermbkjt` - 仓耳萌宝柯基体\*

<p align="center">
  <img
    alt="TsangerMBKJT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermbkjt%2BTsangerMBKJT.png"
  >
</p>

- `tsangertypePackages.tsangermdmwt` - [仓耳萌呆喵尾体](https://tsanger.cn/product/236)

<p align="center">
  <img
    alt="TsangerMDMWT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermdmwt%2BTsangerMDMWT.png"
  >
</p>

- `tsangertypePackages.tsangermengdie` - [仓耳梦蝶体](https://tsanger.cn/product/99)

<p align="center">
  <img
    alt="TsangerMengDie"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermengdie%2BTsangerMengDie.png"
  >
</p>

- `tsangertypePackages.tsangermddt` - [仓耳萌朵朵体](https://tsanger.cn/product/130)

<p align="center">
  <img
    alt="TsangerMDDT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermddt%2BTsangerMDDT.png"
  >
</p>

- `tsangertypePackages.tsangermmdxdzt` -
  [萌萌哒小豆子体](https://tsanger.cn/product/323)

<p align="center">
  <img
    alt="TsangerMMDXDZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermmdxdzt%2BTsangerMMDXDZT.png"
  >
</p>

- `tsangertypePackages.tsangermmjt` - [仓耳萌喵酱](https://tsanger.cn/product/237)

<p align="center">
  <img
    alt="仓耳萌喵酱"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermmjt%2B%E4%BB%93%E8%80%B3%E8%90%8C%E5%96%B5%E9%85%B1.png"
  >
</p>

- `tsangertypePackages.tsangermtls` - [仓耳梦桐隶书](https://tsanger.cn/product/279)

<p align="center">
  <img
    alt="TsangerMTLS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermtls%2BTsangerMTLS.png"
  >
</p>

- `tsangertypePackages.tsangermxlbt` -
  [仓耳梦醒的离别体](https://tsanger.cn/product/280)

<p align="center">
  <img
    alt="TsangerMXLBT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermxlbt%2BTsangerMXLBT.png"
  >
</p>

- `tsangertypePackages.tsangerminghei` -
  [仓耳明黑w01](https://tsanger.cn/product/347)、[w02](https://tsanger.cn/product/348)、[w03](https://tsanger.cn/product/349)、[w04](https://tsanger.cn/product/350)、[w05](https://tsanger.cn/product/351)、[w06](https://tsanger.cn/product/352)、[w07](https://tsanger.cn/product/353)、[w08](https://tsanger.cn/product/354)

<p align="center">
  <img
    alt="TsangerMingHei W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W01.png"
  >
  <br>
  <sub>TsangerMingHei W01</sub>
  <br>
  <img
    alt="TsangerMingHei W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W02.png"
  >
  <br>
  <sub>TsangerMingHei W02</sub>
  <br>
  <img
    alt="TsangerMingHei W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W03.png"
  >
  <br>
  <sub>TsangerMingHei W03</sub>
  <br>
  <img
    alt="TsangerMingHei W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W04.png"
  >
  <br>
  <sub>TsangerMingHei W04</sub>
  <br>
  <img
    alt="TsangerMingHei W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W05.png"
  >
  <br>
  <sub>TsangerMingHei W05</sub>
  <br>
  <img
    alt="TsangerMingHei W06"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W06.png"
  >
  <br>
  <sub>TsangerMingHei W06</sub>
  <br>
  <img
    alt="TsangerMingHei W07"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W07.png"
  >
  <br>
  <sub>TsangerMingHei W07</sub>
  <br>
  <img
    alt="TsangerMingHei W08"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerminghei%2BTsangerMingHei%20W08.png"
  >
  <br>
  <sub>TsangerMingHei W08</sub>
  <br>
</p>

- `tsangertypePackages.tsangermingkai` -
  [仓耳明楷w01](https://tsanger.cn/product/87)、[w02](https://tsanger.cn/product/88)、[w03](https://tsanger.cn/product/89)、[w04](https://tsanger.cn/product/90)

<p align="center">
  <img
    alt="TsangerMingKai W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermingkai%2BTsangerMingKai%20W01.png"
  >
  <br>
  <sub>TsangerMingKai W01</sub>
  <br>
  <img
    alt="TsangerMingKai W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermingkai%2BTsangerMingKai%20W02.png"
  >
  <br>
  <sub>TsangerMingKai W02</sub>
  <br>
  <img
    alt="TsangerMingKai W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermingkai%2BTsangerMingKai%20W03.png"
  >
  <br>
  <sub>TsangerMingKai W03</sub>
  <br>
  <img
    alt="TsangerMingKai W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermingkai%2BTsangerMingKai%20W04.png"
  >
  <br>
  <sub>TsangerMingKai W04</sub>
  <br>
</p>

- `tsangertypePackages.tsangermingyueti` -
  [仓耳明月体](https://tsanger.cn/product/380)

<p align="center">
  <img
    alt="TsangerMingYueTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermingyueti%2BTsangerMingYueTi.png"
  >
</p>

- `tsangertypePackages.tsangermzgt` - [仓耳秘之果](https://tsanger.cn/product/238)

<p align="center">
  <img
    alt="TsangerMZGT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermzgt%2BTsangerMZGT.png"
  >
</p>

- `tsangertypePackages.tsangermochati` - [仓耳抹茶体](https://tsanger.cn/product/281)

<p align="center">
  <img
    alt="TsangerMoChaTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangermochati%2BTsangerMoChaTi.png"
  >
</p>

- `tsangertypePackages.tsangernhsgt` - [仓耳你好时光体](https://tsanger.cn/product/283)

<p align="center">
  <img
    alt="TsangerNHSGT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangernhsgt%2BTsangerNHSGT.png"
  >
</p>

- `tsangertypePackages.tsangernswdqsj` -
  [你是我的全世界](https://tsanger.cn/product/166)

<p align="center">
  <img
    alt="TsangerNSWDQSJ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangernswdqsj%2BTsangerNSWDQSJ.png"
  >
</p>

- `tsangertypePackages.tsangernswdwy` - [仓耳你是我唯一](https://tsanger.cn/product/50)

<p align="center">
  <img
    alt="TsangerNSWDWY"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangernswdwy%2BTsangerNSWDWY.png"
  >
</p>

- `tsangertypePackages.tsangernnszt` - [仓耳暖男手札体](https://tsanger.cn/product/284)

<p align="center">
  <img
    alt="TsangerNNSZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangernnszt%2BTsangerNNSZT.png"
  >
</p>

- `tsangertypePackages.tsangernxt` - [仓耳暖心体](https://tsanger.cn/product/285)

<p align="center">
  <img
    alt="TsangerNXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangernxt%2BTsangerNXT.png"
  >
</p>

- `tsangertypePackages.tsangernwt` - [仓耳女王体](https://tsanger.cn/product/239)

<p align="center">
  <img
    alt="TsangerNWT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangernwt%2BTsangerNWT.png"
  >
</p>

- `tsangertypePackages.tsangerpbt` - [仓耳陪伴体](https://tsanger.cn/product/286)

<p align="center">
  <img
    alt="TsangerPBT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerpbt%2BTsangerPBT.png"
  >
</p>

- `tsangertypePackages.tsangerpmt` - [仓耳缥缈体](https://tsanger.cn/product/287)

<p align="center">
  <img
    alt="TsangerPMT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerpmt%2BTsangerPMT.png"
  >
</p>

- `tsangertypePackages.tsangerqiaoleti` -
  [仓耳巧乐w01](https://tsanger.cn/product/342)、[w02](https://tsanger.cn/product/343)、[w03](https://tsanger.cn/product/344)、[w04](https://tsanger.cn/product/345)、[w05](https://tsanger.cn/product/346)

<p align="center">
  <img
    alt="TsangerQiaoLeTi W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqiaoleti%2BTsangerQiaoLeTi%20W01.png"
  >
  <br>
  <sub>TsangerQiaoLeTi W01</sub>
  <br>
  <img
    alt="TsangerQiaoLeTi W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqiaoleti%2BTsangerQiaoLeTi%20W02.png"
  >
  <br>
  <sub>TsangerQiaoLeTi W02</sub>
  <br>
  <img
    alt="TsangerQiaoLeTi W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqiaoleti%2BTsangerQiaoLeTi%20W03.png"
  >
  <br>
  <sub>TsangerQiaoLeTi W03</sub>
  <br>
  <img
    alt="TsangerQiaoLeTi W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqiaoleti%2BTsangerQiaoLeTi%20W04.png"
  >
  <br>
  <sub>TsangerQiaoLeTi W04</sub>
  <br>
  <img
    alt="TsangerQiaoLeTi W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqiaoleti%2BTsangerQiaoLeTi%20W05.png"
  >
  <br>
  <sub>TsangerQiaoLeTi W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerqeddt` - [仓耳企鹅豆豆体](https://tsanger.cn/product/240)

<p align="center">
  <img
    alt="TsangerQEDDT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqeddt%2BTsangerQEDDT.png"
  >
</p>

- `tsangertypePackages.tsangergqimingti` -
  [仓耳启明体](https://tsanger.cn/product/392)

<p align="center">
  <img
    alt="TsangergQimingTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangergqimingti%2BTsangergQimingTi.png"
  >
</p>

- `tsangertypePackages.tsangerqcynwmt` -
  [仓耳青春以你为名体](https://tsanger.cn/product/288)

<p align="center">
  <img
    alt="TsangerQCYNWMT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqcynwmt%2BTsangerQCYNWMT.png"
  >
</p>

- `tsangertypePackages.tsangerqft` - [仓耳清风体](https://tsanger.cn/product/293)

<p align="center">
  <img
    alt="TsangerQFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqft%2BTsangerQFT.png"
  >
</p>

- `tsangertypePackages.tsangerqfxyt` - [仓耳轻风斜阳体](https://tsanger.cn/product/292)

<p align="center">
  <img
    alt="TsangerQFXYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqfxyt%2BTsangerQFXYT.png"
  >
</p>

- `tsangertypePackages.tsangerqht` - [仓耳清欢体](https://tsanger.cn/product/224)

<p align="center">
  <img
    alt="TsangerQHT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqht%2BTsangerQHT.png"
  >
</p>

- `tsangertypePackages.tsangerqhtgl` -
  [仓耳青禾体w01](https://tsanger.cn/product/219)、[w02](https://tsanger.cn/product/220)、[w03](https://tsanger.cn/product/221)、[w04](https://tsanger.cn/product/222)、[w05](https://tsanger.cn/product/223)

<p align="center">
  <img
    alt="TsangerQHT-GL W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqhtgl%2BTsangerQHT-GL%20W01.png"
  >
  <br>
  <sub>TsangerQHT-GL W01</sub>
  <br>
  <img
    alt="TsangerQHT-GL W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqhtgl%2BTsangerQHT-GL%20W02.png"
  >
  <br>
  <sub>TsangerQHT-GL W02</sub>
  <br>
  <img
    alt="TsangerQHT-GL W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqhtgl%2BTsangerQHT-GL%20W03.png"
  >
  <br>
  <sub>TsangerQHT-GL W03</sub>
  <br>
  <img
    alt="TsangerQHT-GL W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqhtgl%2BTsangerQHT-GL%20W04.png"
  >
  <br>
  <sub>TsangerQHT-GL W04</sub>
  <br>
  <img
    alt="TsangerQHT-GL W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqhtgl%2BTsangerQHT-GL%20W05.png"
  >
  <br>
  <sub>TsangerQHT-GL W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerqingjiti` -
  [仓耳青吉体](https://tsanger.cn/product/359)

<p align="center">
  <img
    alt="TsangerQingJiTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqingjiti%2BTsangerQingJiTi.png"
  >
</p>

- `tsangertypePackages.tsangerqmt` - [仓耳青梅体](https://tsanger.cn/product/289)

<p align="center">
  <img
    alt="TsangerQMT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqmt%2BTsangerQMT.png"
  >
</p>

- `tsangertypePackages.tsangerqnt` - [仓耳青柠体](https://tsanger.cn/product/290)

<p align="center">
  <img
    alt="TsangerQNT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqnt%2BTsangerQNT.png"
  >
</p>

- `tsangertypePackages.tsangerqqxj` - 仓耳青丘小九\*

<p align="center">
  <img
    alt="TsangerQQXJ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqqxj%2BTsangerQQXJ.png"
  >
</p>

- `tsangertypePackages.tsangerqqt` - [仓耳青雀体](https://tsanger.cn/product/291)

<p align="center">
  <img
    alt="TsangerQQT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqqt%2BTsangerQQT.png"
  >
</p>

- `tsangertypePackages.tsangerqingsongti` -
  [仓耳青宋](https://tsanger.cn/product/379)

<p align="center">
  <img
    alt="TsangerQingsongTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqingsongti%2BTsangerQingsongTi.png"
  >
</p>

- `tsangertypePackages.tsangerqxt` - [仓耳晴心体](https://tsanger.cn/product/294)

<p align="center">
  <img
    alt="TsangerQXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqxt%2BTsangerQXT.png"
  >
</p>

- `tsangertypePackages.tsangerqingyou` - [仓耳轻悠体](https://tsanger.cn/product/136)

<p align="center">
  <img
    alt="TsangerQingYou"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqingyou%2BTsangerQingYou.png"
  >
</p>

- `tsangertypePackages.tsangerqingya` -
  [仓耳青雅-方](https://tsanger.cn/product/399)、[圆](https://tsanger.cn/product/398)

<p align="center">
  <img
    alt="TsangerQingYa-F"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqingya%2BTsangerQingYa-F.png"
  >
  <br>
  <sub>TsangerQingYa-F</sub>
  <br>
  <img
    alt="TsangerQingYa-Y"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqingya%2BTsangerQingYa-Y.png"
  >
  <br>
  <sub>TsangerQingYa-Y</sub>
  <br>
</p>

- `tsangertypePackages.tsangerqqmzt` - [亲亲美妆体](https://tsanger.cn/product/253)

<p align="center">
  <img
    alt="TsangerQQMZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqqmzt%2BTsangerQQMZT.png"
  >
</p>

- `tsangertypePackages.tsangerqyt` - [仓耳秋月体](https://tsanger.cn/product/295)

<p align="center">
  <img
    alt="TsangerQYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqyt%2BTsangerQYT.png"
  >
</p>

- `tsangertypePackages.tsangerqczka` - [仓耳全村最可爱](https://tsanger.cn/product/241)

<p align="center">
  <img
    alt="TsangerQCZKA"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerqczka%2BTsangerQCZKA.png"
  >
</p>

- `tsangertypePackages.tsangerquhei` - [仓耳趣黑](https://tsanger.cn/product/336)

<p align="center">
  <img
    alt="TsangerQuHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerquhei%2BTsangerQuHei.png"
  >
</p>

- `tsangertypePackages.tsangerrouhei` - [仓耳柔黑](https://tsanger.cn/product/377)

<p align="center">
  <img
    alt="TsangerRouHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerrouhei%2BTsangerRouHei.png"
  >
</p>

- `tsangertypePackages.tsangerrunhei` -
  [仓耳润黑w01](https://tsanger.cn/product/103)、[w02](https://tsanger.cn/product/104)、[w03](https://tsanger.cn/product/105)

<p align="center">
  <img
    alt="TsangerRunHei-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerrunhei%2BTsangerRunHei-W01.png"
  >
  <br>
  <sub>TsangerRunHei-W01</sub>
  <br>
  <img
    alt="TsangerRunHei-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerrunhei%2BTsangerRunHei-W02.png"
  >
  <br>
  <sub>TsangerRunHei-W02</sub>
  <br>
  <img
    alt="TsangerRunHei-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerrunhei%2BTsangerRunHei-W03.png"
  >
  <br>
  <sub>TsangerRunHei-W03</sub>
  <br>
</p>

- `tsangertypePackages.tsangerruihei` - [仓耳锐黑](https://tsanger.cn/product/360)

<p align="center">
  <img
    alt="TsangerRuiHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerruihei%2BTsangerRuiHei.png"
  >
</p>

- `tsangertypePackages.tsangerssrs` - [仓耳上善若水](https://tsanger.cn/product/19)

<p align="center">
  <img
    alt="TsangerSSRS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerssrs%2BTsangerSSRS.png"
  >
</p>

- `tsangertypePackages.tsangersnxscyt` -
  [神鸟新生创意体](https://tsanger.cn/product/324)

<p align="center">
  <img
    alt="TsangerSNXSCYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersnxscyt%2BTsangerSNXSCYT.png"
  >
</p>

- `tsangertypePackages.tsangersqdddt` -
  [仓耳神奇的豆豆体](https://tsanger.cn/product/242)

<p align="center">
  <img
    alt="TsangerSQDDDT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersqdddt%2BTsangerSQDDDT.png"
  >
</p>

- `tsangertypePackages.tsangershuhei` - [仓耳曙黑](https://tsanger.cn/product/394)

<p align="center">
  <img
    alt="TsangerShuHei"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangershuhei%2BTsangerShuHei.png"
  >
</p>

- `tsangertypePackages.tsangersirouti` - [仓耳丝柔体](https://tsanger.cn/product/378)

<p align="center">
  <img
    alt="TsangerSiRongTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersirouti%2BTsangerSiRongTi.png"
  >
</p>

- `tsangertypePackages.tsangersyxk` - [仓耳丝摇行楷](https://tsanger.cn/product/225)

<p align="center">
  <img
    alt="TsangerSYXK"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersyxk%2BTsangerSYXK.png"
  >
</p>

- `tsangertypePackages.tsangersycxft` -
  [仓耳四叶草的幸福体](https://tsanger.cn/product/296)

<p align="center">
  <img
    alt="TsangerSYCXFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersycxft%2BTsangerSYCXFT.png"
  >
</p>

- `tsangertypePackages.tsangersgt` - [松果体](https://tsanger.cn/product/325)

<p align="center">
  <img
    alt="TsangerSGT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersgt%2BTsangerSGT.png"
  >
</p>

- `tsangertypePackages.tsangersongkai` - [仓耳宋楷](https://tsanger.cn/product/397)

<p align="center">
  <img
    alt="TsangerSongKai"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersongkai%2BTsangerSongKai.png"
  >
</p>

- `tsangertypePackages.tsangersxt` - [仓耳苏心体](https://tsanger.cn/product/297)

<p align="center">
  <img
    alt="TsangerSXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangersxt%2BTsangerSXT.png"
  >
</p>

- `tsangertypePackages.tsangertmmt` - [仓耳甜蜜蜜体](https://tsanger.cn/product/299)

<p align="center">
  <img
    alt="TsangerTMMT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertmmt%2BTsangerTMMT.png"
  >
</p>

- `tsangertypePackages.tsangertmtgl` -
  [仓耳天沐体w01](https://tsanger.cn/product/66)、[w02](https://tsanger.cn/product/67)、[w03](https://tsanger.cn/product/68)、[w04](https://tsanger.cn/product/69)、[w05](https://tsanger.cn/product/70)

<p align="center">
  <img
    alt="TsangerTMT-GL W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertmtgl%2BTsangerTMT-GL%20W01.png"
  >
  <br>
  <sub>TsangerTMT-GL W01</sub>
  <br>
  <img
    alt="TsangerTMT-GL W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertmtgl%2BTsangerTMT-GL%20W02.png"
  >
  <br>
  <sub>TsangerTMT-GL W02</sub>
  <br>
  <img
    alt="TsangerTMT-GL W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertmtgl%2BTsangerTMT-GL%20W03.png"
  >
  <br>
  <sub>TsangerTMT-GL W03</sub>
  <br>
  <img
    alt="TsangerTMT-GL W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertmtgl%2BTsangerTMT-GL%20W04.png"
  >
  <br>
  <sub>TsangerTMT-GL W04</sub>
  <br>
  <img
    alt="TsangerTMT-GL W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertmtgl%2BTsangerTMT-GL%20W05.png"
  >
  <br>
  <sub>TsangerTMT-GL W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangertqxk` - [仓耳天群行楷](https://tsanger.cn/product/71)

<p align="center">
  <img
    alt="TsangerTQXK"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertqxk%2BTsangerTQXK.png"
  >
</p>

- `tsangertypePackages.tsangertsllt` - [仓耳天锁乐乐体](https://tsanger.cn/product/298)

<p align="center">
  <img
    alt="TsangerTSLLT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertsllt%2BTsangerTSLLT.png"
  >
</p>

- `tsangertypePackages.tsangertft` - [仓耳听风体](https://tsanger.cn/product/300)

<p align="center">
  <img
    alt="TsangerTFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertft%2BTsangerTFT.png"
  >
</p>

- `tsangertypePackages.tsangertzt` - [仓耳同桌体](https://tsanger.cn/product/301)

<p align="center">
  <img
    alt="TsangerTZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangertzt%2BTsangerTZT.png"
  >
</p>

- `tsangertypePackages.tsangerty` -
  [仓耳涂鸦体w01](https://tsanger.cn/product/100)、[w02](https://tsanger.cn/product/101)、[w03](https://tsanger.cn/product/102)

<p align="center">
  <img
    alt="TsangerTY-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerty%2BTsangerTY-W02.png"
  >
  <br>
  <sub>TsangerTY-W02</sub>
  <br>
  <img
    alt="TsangerTY-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerty%2BTsangerTY-W03.png"
  >
  <br>
  <sub>TsangerTY-W03</sub>
  <br>
  <img
    alt="TsangerTYT-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerty%2BTsangerTYT-W01.png"
  >
  <br>
  <sub>TsangerTYT-W01</sub>
  <br>
</p>

- `tsangertypePackages.tsangerwdxsjf` - [仓耳万东行书](https://tsanger.cn/product/26)

<p align="center">
  <img
    alt="仓耳万东行书"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerwdxsjf%2B%E4%BB%93%E8%80%B3%E4%B8%87%E4%B8%9C%E8%A1%8C%E4%B9%A6.png"
  >
</p>

- `tsangertypePackages.tsangerwlrjt` - [未来日记体](https://tsanger.cn/product/326)

<p align="center">
  <img
    alt="TsangerWLRJT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerwlrjt%2BTsangerWLRJT.png"
  >
</p>

- `tsangertypePackages.tsangerwgxbqct` -
  [仓耳无个性不青春体](https://tsanger.cn/product/243)

<p align="center">
  <img
    alt="TsangerWGXBQCT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerwgxbqct%2BTsangerWGXBQCT.png"
  >
</p>

- `tsangertypePackages.tsangerwlsft` - [仓耳无量寿福体](https://tsanger.cn/product/331)

<p align="center">
  <img
    alt="TsangerWLSFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerwlsft%2BTsangerWLSFT.png"
  >
</p>

- `tsangertypePackages.tsangerxzzxyzt` -
  [仓耳向左走向右走体](https://tsanger.cn/product/303)

<p align="center">
  <img
    alt="TsangerXZZXYZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxzzxyzt%2BTsangerXZZXYZT.png"
  >
</p>

- `tsangertypePackages.tsangerxbks` - [仓耳小白楷书](https://tsanger.cn/product/332)

<p align="center">
  <img
    alt="TsangerXBKS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxbks%2BTsangerXBKS.png"
  >
</p>

- `tsangertypePackages.tsangergzt` - [仓耳小百万](https://tsanger.cn/product/264)

<p align="center">
  <img
    alt="TsangerGZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangergzt%2BTsangerGZT.png"
  >
</p>

- `tsangertypePackages.tsangerxbxs` - [仓耳小白行书](https://tsanger.cn/product/333)

<p align="center">
  <img
    alt="TsangerXBXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxbxs%2BTsangerXBXS.png"
  >
</p>

- `tsangertypePackages.tsangerxdet` - [仓耳小点儿体](https://tsanger.cn/product/244)

<p align="center">
  <img
    alt="TsangerXDET"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxdet%2BTsangerXDET.png"
  >
</p>

- `tsangertypePackages.tsangerxft` - [仓耳小方体](https://tsanger.cn/product/304)

<p align="center">
  <img
    alt="TsangerXFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxft%2BTsangerXFT.png"
  >
</p>

- `tsangertypePackages.tsangerxka` -
  [仓耳小可爱体w01](https://tsanger.cn/product/72)、[w02](https://tsanger.cn/product/73)、[w03](https://tsanger.cn/product/74)、[w04](https://tsanger.cn/product/75)、[w05](https://tsanger.cn/product/76)、[w06](https://tsanger.cn/product/77)

<p align="center">
  <img
    alt="TsangerXKA-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxka%2BTsangerXKA-W01.png"
  >
  <br>
  <sub>TsangerXKA-W01</sub>
  <br>
  <img
    alt="TsangerXKA-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxka%2BTsangerXKA-W02.png"
  >
  <br>
  <sub>TsangerXKA-W02</sub>
  <br>
  <img
    alt="TsangerXKA-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxka%2BTsangerXKA-W03.png"
  >
  <br>
  <sub>TsangerXKA-W03</sub>
  <br>
  <img
    alt="TsangerXKA-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxka%2BTsangerXKA-W04.png"
  >
  <br>
  <sub>TsangerXKA-W04</sub>
  <br>
  <img
    alt="TsangerXKA-W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxka%2BTsangerXKA-W05.png"
  >
  <br>
  <sub>TsangerXKA-W05</sub>
  <br>
  <img
    alt="TsangerXKA-W06"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxka%2BTsangerXKA-W06.png"
  >
  <br>
  <sub>TsangerXKA-W06</sub>
  <br>
</p>

- `tsangertypePackages.tsangerxmmt` -
  [仓耳小漫漫体w01](https://tsanger.cn/product/78)、[w02](https://tsanger.cn/product/79)、[w03](https://tsanger.cn/product/80)、[w04](https://tsanger.cn/product/81)、[w05](https://tsanger.cn/product/82)

<p align="center">
  <img
    alt="TsangerXMMT W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxmmt%2BTsangerXMMT%20W01.png"
  >
  <br>
  <sub>TsangerXMMT W01</sub>
  <br>
  <img
    alt="TsangerXMMT W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxmmt%2BTsangerXMMT%20W02.png"
  >
  <br>
  <sub>TsangerXMMT W02</sub>
  <br>
  <img
    alt="TsangerXMMT W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxmmt%2BTsangerXMMT%20W03.png"
  >
  <br>
  <sub>TsangerXMMT W03</sub>
  <br>
  <img
    alt="TsangerXMMT W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxmmt%2BTsangerXMMT%20W04.png"
  >
  <br>
  <sub>TsangerXMMT W04</sub>
  <br>
  <img
    alt="TsangerXMMT W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxmmt%2BTsangerXMMT%20W05.png"
  >
  <br>
  <sub>TsangerXMMT W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerfgxsxst` -
  [飞哥潇洒行书](https://tsanger.cn/product/335)

<p align="center">
  <img
    alt="TsangerFGXSXST"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerfgxsxst%2BTsangerFGXSXST.png"
  >
</p>

- `tsangertypePackages.tsangerxspt` - [仓耳小视频体](https://tsanger.cn/product/367)

<p align="center">
  <img
    alt="TsangerXSPT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxspt%2BTsangerXSPT.png"
  >
</p>

- `tsangertypePackages.tsangerxwndm` - [仓耳小蜗牛的梦](https://tsanger.cn/product/245)

<p align="center">
  <img
    alt="TsangerXWNDM"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxwndm%2BTsangerXWNDM.png"
  >
</p>

- `tsangertypePackages.tsangerxxhct` - [仓耳小小火柴体](https://tsanger.cn/product/305)

<p align="center">
  <img
    alt="TsangerXXHCT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxxhct%2BTsangerXXHCT.png"
  >
</p>

- `tsangertypePackages.tsangerxxmgt` - [仓耳小小芒果体](https://tsanger.cn/product/306)

<p align="center">
  <img
    alt="TsangerXXMGT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxxmgt%2BTsangerXXMGT.png"
  >
</p>

- `tsangertypePackages.tsangerxyxs` - [仓耳逍遥行书](https://tsanger.cn/product/137)

<p align="center">
  <img
    alt="TsangerXYXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxyxs%2BTsangerXYXS.png"
  >
</p>

- `tsangertypePackages.tsangerxysj` - [仓耳小雅手迹](https://tsanger.cn/product/83)

<p align="center">
  <img
    alt="TsangerXYSJ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxysj%2BTsangerXYSJ.png"
  >
</p>

- `tsangertypePackages.tsangerxytxt` - [仓耳小雨同学体](https://tsanger.cn/product/307)

<p align="center">
  <img
    alt="TsangerXYTXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxytxt%2BTsangerXYTXT.png"
  >
</p>

- `tsangertypePackages.tsangerxyzxft` -
  [仓耳下一站幸福体](https://tsanger.cn/product/302)

<p align="center">
  <img
    alt="TsangerXYZXFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxyzxft%2BTsangerXYZXFT.png"
  >
</p>

- `tsangertypePackages.tsangerxcks` - [仓耳星辰楷书](https://tsanger.cn/product/334)

<p align="center">
  <img
    alt="TsangerXCKS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxcks%2BTsangerXCKS.png"
  >
</p>

- `tsangertypePackages.tsangerxflzt` - [仓耳幸福乐章体](https://tsanger.cn/product/247)

<p align="center">
  <img
    alt="TsangerXFLZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxflzt%2BTsangerXFLZT.png"
  >
</p>

- `tsangertypePackages.tsangerxhsong` - [仓耳星汉宋](https://tsanger.cn/product/372)

<p align="center">
  <img
    alt="TsangerXHSong"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxhsong%2BTsangerXHSong.png"
  >
</p>

- `tsangertypePackages.tsangerxxt` - [仓耳心星体](https://tsanger.cn/product/246)

<p align="center">
  <img
    alt="TsangerXXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxxt%2BTsangerXXT.png"
  >
</p>

- `tsangertypePackages.tsangerxinyanti` -
  [仓耳新颜体](https://tsanger.cn/product/338)

<p align="center">
  <img
    alt="TsangerXinYanTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxinyanti%2BTsangerXinYanTi.png"
  >
</p>

- `tsangertypePackages.tsangerxinyueti` -
  [仓耳新悦体](https://tsanger.cn/product/340)

<p align="center">
  <img
    alt="TsangerXinYueTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxinyueti%2BTsangerXinYueTi.png"
  >
</p>

- `tsangertypePackages.tsangerxyt` - [仓耳欣月体](https://tsanger.cn/product/308)

<p align="center">
  <img
    alt="TsangerXYT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxyt%2BTsangerXYT.png"
  >
</p>

- `tsangertypePackages.tsangerxxxs` - [仓耳绣线行书](https://tsanger.cn/product/309)

<p align="center">
  <img
    alt="TsangerXXXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxxxs%2BTsangerXXXS.png"
  >
</p>

- `tsangertypePackages.tsangerxuansan` -
  仓耳玄三01：[W01](https://tsanger.cn/product/15)、[W02](https://tsanger.cn/product/16)、[W03](https://tsanger.cn/product/167)、[W04](https://tsanger.cn/product/168)、[W05](https://tsanger.cn/product/169)；仓耳玄三02：[W01](https://tsanger.cn/product/170)、[W02](https://tsanger.cn/product/171)、[W03](https://tsanger.cn/product/172)、[W04](https://tsanger.cn/product/173)、[W05](https://tsanger.cn/product/174)；仓耳玄三03：[W01](https://tsanger.cn/product/175)、[W02](https://tsanger.cn/product/176)、[W03](https://tsanger.cn/product/18)、[W04](https://tsanger.cn/product/177)、[W05](https://tsanger.cn/product/178)；仓耳玄三04：[W01](https://tsanger.cn/product/179)、[W02](https://tsanger.cn/product/180)、[W03](https://tsanger.cn/product/181)、[W04](https://tsanger.cn/product/182)、[W05](https://tsanger.cn/product/183)；仓耳玄三M：[W01](https://tsanger.cn/product/184)、[W02](https://tsanger.cn/product/185)、[W03](https://tsanger.cn/product/186)、[W04](https://tsanger.cn/product/187)、[W05](https://tsanger.cn/product/188);

<p align="center">
  <img
    alt="TsangerXuanSan01JF W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan01JF%20W01.png"
  >
  <br>
  <sub>TsangerXuanSan01JF W01</sub>
  <br>
  <img
    alt="TsangerXuanSan01JF W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan01JF%20W02.png"
  >
  <br>
  <sub>TsangerXuanSan01JF W02</sub>
  <br>
  <img
    alt="TsangerXuanSan01JF W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan01JF%20W03.png"
  >
  <br>
  <sub>TsangerXuanSan01JF W03</sub>
  <br>
  <img
    alt="TsangerXuanSan01JF W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan01JF%20W04.png"
  >
  <br>
  <sub>TsangerXuanSan01JF W04</sub>
  <br>
  <img
    alt="TsangerXuanSan01JF W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan01JF%20W05.png"
  >
  <br>
  <sub>TsangerXuanSan01JF W05</sub>
  <br>
  <img
    alt="TsangerXuanSan02 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan02%20W01.png"
  >
  <br>
  <sub>TsangerXuanSan02 W01</sub>
  <br>
  <img
    alt="TsangerXuanSan02 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan02%20W02.png"
  >
  <br>
  <sub>TsangerXuanSan02 W02</sub>
  <br>
  <img
    alt="TsangerXuanSan02 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan02%20W03.png"
  >
  <br>
  <sub>TsangerXuanSan02 W03</sub>
  <br>
  <img
    alt="TsangerXuanSan02 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan02%20W04.png"
  >
  <br>
  <sub>TsangerXuanSan02 W04</sub>
  <br>
  <img
    alt="TsangerXuanSan02 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan02%20W05.png"
  >
  <br>
  <sub>TsangerXuanSan02 W05</sub>
  <br>
  <img
    alt="TsangerXuanSan03 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan03%20W01.png"
  >
  <br>
  <sub>TsangerXuanSan03 W01</sub>
  <br>
  <img
    alt="TsangerXuanSan03 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan03%20W02.png"
  >
  <br>
  <sub>TsangerXuanSan03 W02</sub>
  <br>
  <img
    alt="TsangerXuanSan03 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan03%20W03.png"
  >
  <br>
  <sub>TsangerXuanSan03 W03</sub>
  <br>
  <img
    alt="TsangerXuanSan03 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan03%20W04.png"
  >
  <br>
  <sub>TsangerXuanSan03 W04</sub>
  <br>
  <img
    alt="TsangerXuanSan03 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan03%20W05.png"
  >
  <br>
  <sub>TsangerXuanSan03 W05</sub>
  <br>
  <img
    alt="TsangerXuanSan04 W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan04%20W01.png"
  >
  <br>
  <sub>TsangerXuanSan04 W01</sub>
  <br>
  <img
    alt="TsangerXuanSan04 W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan04%20W02.png"
  >
  <br>
  <sub>TsangerXuanSan04 W02</sub>
  <br>
  <img
    alt="TsangerXuanSan04 W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan04%20W03.png"
  >
  <br>
  <sub>TsangerXuanSan04 W03</sub>
  <br>
  <img
    alt="TsangerXuanSan04 W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan04%20W04.png"
  >
  <br>
  <sub>TsangerXuanSan04 W04</sub>
  <br>
  <img
    alt="TsangerXuanSan04 W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSan04%20W05.png"
  >
  <br>
  <sub>TsangerXuanSan04 W05</sub>
  <br>
  <img
    alt="TsangerXuanSanM W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSanM%20W01.png"
  >
  <br>
  <sub>TsangerXuanSanM W01</sub>
  <br>
  <img
    alt="TsangerXuanSanM W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSanM%20W02.png"
  >
  <br>
  <sub>TsangerXuanSanM W02</sub>
  <br>
  <img
    alt="TsangerXuanSanM W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSanM%20W03.png"
  >
  <br>
  <sub>TsangerXuanSanM W03</sub>
  <br>
  <img
    alt="TsangerXuanSanM W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSanM%20W04.png"
  >
  <br>
  <sub>TsangerXuanSanM W04</sub>
  <br>
  <img
    alt="TsangerXuanSanM W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxuansan%2BTsangerXuanSanM%20W05.png"
  >
  <br>
  <sub>TsangerXuanSanM W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerxiuzhenti` -
  [仓耳秀蓁体](https://tsanger.cn/product/374)

<p align="center">
  <img
    alt="TsangerXiuZhenTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxiuzhenti%2BTsangerXiuZhenTi.png"
  >
</p>

- `tsangertypePackages.tsangerxiyuanti` -
  [仓耳细圆体](https://tsanger.cn/product/361)

<p align="center">
  <img
    alt="TsangerXiYuanTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxiyuanti%2BTsangerXiYuanTi.png"
  >
</p>

- `tsangertypePackages.tsangerxmsltht` -
  [寻梦十里桃花体](https://tsanger.cn/product/327)

<p align="center">
  <img
    alt="TsangerXMSLTHT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxmsltht%2BTsangerXMSLTHT.png"
  >
</p>

- `tsangertypePackages.tsangerxzmxsxt` -
  [寻找魔仙手写体](https://tsanger.cn/product/254)

<p align="center">
  <img
    alt="TsangerXZMXSXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerxzmxsxt%2BTsangerXZMXSXT.png"
  >
</p>

- `tsangertypePackages.tsangerygmmt` - [仓耳阳光明媚体](https://tsanger.cn/product/248)

<p align="center">
  <img
    alt="TsangerYGMMT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerygmmt%2BTsangerYGMMT.png"
  >
</p>

- `tsangertypePackages.tsangeryangmingti` -
  [仓耳阳明体](https://tsanger.cn/product/382)

<p align="center">
  <img
    alt="TsangerYangMingTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryangmingti%2BTsangerYangMingTi.png"
  >
</p>

- `tsangertypePackages.tsangerygxs` - [仓耳尧光行书](https://tsanger.cn/product/368)

<p align="center">
  <img
    alt="TsangerYGXS"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerygxs%2BTsangerYGXS.png"
  >
</p>

- `tsangertypePackages.tsangeryasong` - [仓耳雅宋](https://tsanger.cn/product/384)

<p align="center">
  <img
    alt="Tsanger YaSong"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryasong%2BTsanger%20YaSong.png"
  >
</p>

- `tsangertypePackages.tsangeryayueti` - [仓耳雅月体](https://tsanger.cn/product/388)

<p align="center">
  <img
    alt="TsangerYayueTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryayueti%2BTsangerYayueTi.png"
  >
</p>

- `tsangertypePackages.tsangeryzlt` - [仓耳叶之灵体](https://tsanger.cn/product/249)

<p align="center">
  <img
    alt="TsangerYZLT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryzlt%2BTsangerYZLT.png"
  >
</p>

- `tsangertypePackages.tsangeryinghe` - [仓耳硬核体](https://tsanger.cn/product/120)

<p align="center">
  <img
    alt="TsangerYingHe"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryinghe%2BTsangerYingHe.png"
  >
</p>

- `tsangertypePackages.tsangeryihei` -
  [仓耳逸黑W01](https://tsanger.cn/product/138)、[W02](https://tsanger.cn/product/139)、[W03](https://tsanger.cn/product/140)、[W04](https://tsanger.cn/product/141)、[W05](https://tsanger.cn/product/142)

<p align="center">
  <img
    alt="TsangerYiHei-W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryihei%2BTsangerYiHei-W01.png"
  >
  <br>
  <sub>TsangerYiHei-W01</sub>
  <br>
  <img
    alt="TsangerYiHei-W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryihei%2BTsangerYiHei-W02.png"
  >
  <br>
  <sub>TsangerYiHei-W02</sub>
  <br>
  <img
    alt="TsangerYiHei-W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryihei%2BTsangerYiHei-W03.png"
  >
  <br>
  <sub>TsangerYiHei-W03</sub>
  <br>
  <img
    alt="TsangerYiHei-W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryihei%2BTsangerYiHei-W04.png"
  >
  <br>
  <sub>TsangerYiHei-W04</sub>
  <br>
  <img
    alt="TsangerYiHei-W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryihei%2BTsangerYiHei-W05.png"
  >
  <br>
  <sub>TsangerYiHei-W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangeryryzt` - [仓耳易燃易炸体](https://tsanger.cn/product/310)

<p align="center">
  <img
    alt="TsangerYRYZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryryzt%2BTsangerYRYZT.png"
  >
</p>

- `tsangertypePackages.tsangerysbdt` - [仓耳意式布丁体](https://tsanger.cn/product/311)

<p align="center">
  <img
    alt="TsangerYSBDT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerysbdt%2BTsangerYSBDT.png"
  >
</p>

- `tsangertypePackages.tsangeryisong` - [仓耳宜宋](https://tsanger.cn/product/364)

<p align="center">
  <img
    alt="TsangerYiSong"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryisong%2BTsangerYiSong.png"
  >
</p>

- `tsangertypePackages.tsangeryycft` - [仓耳一夜春风体](https://tsanger.cn/product/250)

<p align="center">
  <img
    alt="TsangerYYCFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryycft%2BTsangerYYCFT.png"
  >
</p>

- `tsangertypePackages.tsangeryouran` - [仓耳悠然体](https://tsanger.cn/product/85)

<p align="center">
  <img
    alt="TsangerYouRan"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryouran%2BTsangerYouRan.png"
  >
</p>

- `tsangertypePackages.tsangeryctgl` -
  [仓耳羽辰体W01](https://tsanger.cn/product/125)、[W02](https://tsanger.cn/product/126)、[W03](https://tsanger.cn/product/127)、[W04](https://tsanger.cn/product/128)、[W05](https://tsanger.cn/product/129)

<p align="center">
  <img
    alt="TsangerYCT-GL W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryctgl%2BTsangerYCT-GL%20W01.png"
  >
  <br>
  <sub>TsangerYCT-GL W01</sub>
  <br>
  <img
    alt="TsangerYCT-GL W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryctgl%2BTsangerYCT-GL%20W02.png"
  >
  <br>
  <sub>TsangerYCT-GL W02</sub>
  <br>
  <img
    alt="TsangerYCT-GL W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryctgl%2BTsangerYCT-GL%20W03.png"
  >
  <br>
  <sub>TsangerYCT-GL W03</sub>
  <br>
  <img
    alt="TsangerYCT-GL W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryctgl%2BTsangerYCT-GL%20W04.png"
  >
  <br>
  <sub>TsangerYCT-GL W04</sub>
  <br>
  <img
    alt="TsangerYCT-GL W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryctgl%2BTsangerYCT-GL%20W05.png"
  >
  <br>
  <sub>TsangerYCT-GL W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerybt` - 仓耳元宝体\*

<p align="center">
  <img
    alt="TsangerYBT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerybt%2BTsangerYBT.png"
  >
</p>

- `tsangertypePackages.tsangeryuedong` - [仓耳悦动体](https://tsanger.cn/product/86)

<p align="center">
  <img
    alt="仓耳悦动体"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryuedong%2B%E4%BB%93%E8%80%B3%E6%82%A6%E5%8A%A8%E4%BD%93.png"
  >
</p>

- `tsangertypePackages.tsangerymt` - [仓耳月满体](https://tsanger.cn/product/315)

<p align="center">
  <img
    alt="TsangerYMT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerymt%2BTsangerYMT.png"
  >
</p>

- `tsangertypePackages.tsangeryukai` - [仓耳玉楷](https://tsanger.cn/product/362)

<p align="center">
  <img
    alt="TsangerYuKai"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryukai%2BTsangerYuKai.png"
  >
</p>

- `tsangertypePackages.tsangerylt` - [仓耳鱼乐体](https://tsanger.cn/product/312)

<p align="center">
  <img
    alt="TsangerYLT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerylt%2BTsangerYLT.png"
  >
</p>

- `tsangertypePackages.tsangeryhstt` - [仓耳云海松涛体](https://tsanger.cn/product/20)

<p align="center">
  <img
    alt="TsangerYHSTT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryhstt%2BTsangerYHSTT.png"
  >
</p>

- `tsangertypePackages.tsangeryunhei` -
  [仓耳云黑-W01](https://tsanger.cn/product/9)、[W02](https://tsanger.cn/product/10)、[W03](https://tsanger.cn/product/11)、[W04](https://tsanger.cn/product/12)、[W05](https://tsanger.cn/product/13)、[W06](https://tsanger.cn/product/28)、[W07](https://tsanger.cn/product/29)、[W08](https://tsanger.cn/product/30)

<p align="center">
  <img
    alt="TsangerYunHei W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W01.png"
  >
  <br>
  <sub>TsangerYunHei W01</sub>
  <br>
  <img
    alt="TsangerYunHei W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W02.png"
  >
  <br>
  <sub>TsangerYunHei W02</sub>
  <br>
  <img
    alt="TsangerYunHei W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W03.png"
  >
  <br>
  <sub>TsangerYunHei W03</sub>
  <br>
  <img
    alt="TsangerYunHei W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W04.png"
  >
  <br>
  <sub>TsangerYunHei W04</sub>
  <br>
  <img
    alt="TsangerYunHei W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W05.png"
  >
  <br>
  <sub>TsangerYunHei W05</sub>
  <br>
  <img
    alt="TsangerYunHei W06"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W06.png"
  >
  <br>
  <sub>TsangerYunHei W06</sub>
  <br>
  <img
    alt="TsangerYunHei W07"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W07.png"
  >
  <br>
  <sub>TsangerYunHei W07</sub>
  <br>
  <img
    alt="TsangerYunHei W08"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryunhei%2BTsangerYunHei%20W08.png"
  >
  <br>
  <sub>TsangerYunHei W08</sub>
  <br>
</p>

- `tsangertypePackages.tsangeryxt` - [仓耳云轩体](https://tsanger.cn/product/27)

<p align="center">
  <img
    alt="TsangerYXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryxt%2BTsangerYXT.png"
  >
</p>

- `tsangertypePackages.tsangeryxxt` - [仓耳雨潇潇体](https://tsanger.cn/product/313)

<p align="center">
  <img
    alt="TsangerYXXT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangeryxxt%2BTsangerYXXT.png"
  >
</p>

- `tsangertypePackages.tsangerzjnxnt` -
  [仓耳再见那些年体](https://tsanger.cn/product/316)

<p align="center">
  <img
    alt="TsangerZJNXNT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzjnxnt%2BTsangerZJNXNT.png"
  >
</p>

- `tsangertypePackages.tsangerzgft` - [仓耳曾国藩体](https://tsanger.cn/product/383)

<p align="center">
  <img
    alt="TsangerZGFT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzgft%2BTsangerZGFT.png"
  >
</p>

- `tsangertypePackages.tsangerzyxwzt` -
  [仓耳章鱼小丸子体](https://tsanger.cn/product/121)

<p align="center">
  <img
    alt="TsangerZYXWZT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzyxwzt%2BTsangerZYXWZT.png"
  >
</p>

- `tsangertypePackages.tsangerzhenzhuti` -
  [仓耳珍珠体](https://tsanger.cn/product/369)

<p align="center">
  <img
    alt="TsangerZhenZhuTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzhenzhuti%2BTsangerZhenZhuTi.png"
  >
</p>

- `tsangertypePackages.tsangerzqtgl` -
  [仓耳知曲体W01](https://tsanger.cn/product/115)、[W02](https://tsanger.cn/product/116)、[W03](https://tsanger.cn/product/117)、[W04](https://tsanger.cn/product/118)、[W05](https://tsanger.cn/product/119)

<p align="center">
  <img
    alt="TsangerZQT-GL W01"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzqtgl%2BTsangerZQT-GL%20W01.png"
  >
  <br>
  <sub>TsangerZQT-GL W01</sub>
  <br>
  <img
    alt="TsangerZQT-GL W02"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzqtgl%2BTsangerZQT-GL%20W02.png"
  >
  <br>
  <sub>TsangerZQT-GL W02</sub>
  <br>
  <img
    alt="TsangerZQT-GL W03"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzqtgl%2BTsangerZQT-GL%20W03.png"
  >
  <br>
  <sub>TsangerZQT-GL W03</sub>
  <br>
  <img
    alt="TsangerZQT-GL W04"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzqtgl%2BTsangerZQT-GL%20W04.png"
  >
  <br>
  <sub>TsangerZQT-GL W04</sub>
  <br>
  <img
    alt="TsangerZQT-GL W05"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzqtgl%2BTsangerZQT-GL%20W05.png"
  >
  <br>
  <sub>TsangerZQT-GL W05</sub>
  <br>
</p>

- `tsangertypePackages.tsangerzxkzn` - [仓耳只想看着你](https://tsanger.cn/product/317)

<p align="center">
  <img
    alt="TsangerZXKZN"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzxkzn%2BTsangerZXKZN.png"
  >
</p>

- `tsangertypePackages.tsangerzhixinti` -
  [仓耳知新体](https://tsanger.cn/product/389)

<p align="center">
  <img
    alt="TsangerZhiXinTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzhixinti%2BTsangerZhiXinTi.png"
  >
</p>

- `tsangertypePackages.tsangerzyxwq` - [仓耳治愈系文青](https://tsanger.cn/product/318)

<p align="center">
  <img
    alt="TsangerZYXWQ"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzyxwq%2BTsangerZYXWQ.png"
  >
</p>

- `tsangertypePackages.tsangerzxylt` - [仓耳周鑫游龙体](https://tsanger.cn/product/358)

<p align="center">
  <img
    alt="TsangerZXYLT"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzxylt%2BTsangerZXYLT.png"
  >
</p>

- `tsangertypePackages.tsangerzhuangyuankai` -
  [仓耳状元楷](https://tsanger.cn/product/391)

<p align="center">
  <img
    alt="TsangerZhuangYuanKai"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzhuangyuankai%2BTsangerZhuangYuanKai.png"
  >
</p>

- `tsangertypePackages.tsangerzhuyanti` -
  [仓耳竹言体](https://tsanger.cn/product/375)

<p align="center">
  <img
    alt="TsangerZhuYanTi"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzhuyanti%2BTsangerZhuYanTi.png"
  >
</p>

- `tsangertypePackages.tsangerzongheng` -
  [仓耳纵横体](https://tsanger.cn/product/122)

<p align="center">
  <img
    alt="TsangerZongHeng"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/tsangertype/tsangertype-tsangerzongheng%2BTsangerZongHeng.png"
  >
</p>

> \*：该字体在[仓耳字库网站](https://tsanger.cn) 上无法找到对应产品页。

### ZiHi（社群）字型系列字体（字嗨字型系列字體）- `buttaiwanPackages`

> [!TIP]
>
> 通过 `buttaiwan-fonts` 来安装所有 ZiHi（社群）字型系列字体。

- `buttaiwanPackages.genkimin2-jp` -
  [GenKiMin2 JP / 源起明朝](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenKiMin2 JP EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-jp%2BGenKiMin2%20JP%20EL.png"
  >
  <br>
  <sub>GenKiMin2 JP EL</sub>
  <br>
  <img
    alt="GenKiMin2 JP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-jp%2BGenKiMin2%20JP%20L.png"
  >
  <br>
  <sub>GenKiMin2 JP L</sub>
  <br>
  <img
    alt="GenKiMin2 JP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-jp%2BGenKiMin2%20JP%20R.png"
  >
  <br>
  <sub>GenKiMin2 JP R</sub>
  <br>
  <img
    alt="GenKiMin2 JP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-jp%2BGenKiMin2%20JP%20M.png"
  >
  <br>
  <sub>GenKiMin2 JP M</sub>
  <br>
  <img
    alt="GenKiMin2 JP SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-jp%2BGenKiMin2%20JP%20SB.png"
  >
  <br>
  <sub>GenKiMin2 JP SB</sub>
  <br>
  <img
    alt="GenKiMin2 JP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-jp%2BGenKiMin2%20JP%20B.png"
  >
  <br>
  <sub>GenKiMin2 JP B</sub>
  <br>
  <img
    alt="GenKiMin2 JP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-jp%2BGenKiMin2%20JP%20H.png"
  >
  <br>
  <sub>GenKiMin2 JP H</sub>
  <br>
</p>

- `buttaiwanPackages.genkimin2-pjp` -
  [GenKiMin2 PJP / 源起明朝P](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenKiMin2 PJP EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-pjp%2BGenKiMin2%20PJP%20EL.png"
  >
  <br>
  <sub>GenKiMin2 PJP EL</sub>
  <br>
  <img
    alt="GenKiMin2 PJP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-pjp%2BGenKiMin2%20PJP%20L.png"
  >
  <br>
  <sub>GenKiMin2 PJP L</sub>
  <br>
  <img
    alt="GenKiMin2 PJP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-pjp%2BGenKiMin2%20PJP%20R.png"
  >
  <br>
  <sub>GenKiMin2 PJP R</sub>
  <br>
  <img
    alt="GenKiMin2 PJP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-pjp%2BGenKiMin2%20PJP%20M.png"
  >
  <br>
  <sub>GenKiMin2 PJP M</sub>
  <br>
  <img
    alt="GenKiMin2 PJP SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-pjp%2BGenKiMin2%20PJP%20SB.png"
  >
  <br>
  <sub>GenKiMin2 PJP SB</sub>
  <br>
  <img
    alt="GenKiMin2 PJP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-pjp%2BGenKiMin2%20PJP%20B.png"
  >
  <br>
  <sub>GenKiMin2 PJP B</sub>
  <br>
  <img
    alt="GenKiMin2 PJP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-pjp%2BGenKiMin2%20PJP%20H.png"
  >
  <br>
  <sub>GenKiMin2 PJP H</sub>
  <br>
</p>

- `buttaiwanPackages.genkimin2-tc` -
  [GenKiMin2 TC / 源起明體丹](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenKiMin2 TC EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tc%2BGenKiMin2%20TC%20EL.png"
  >
  <br>
  <sub>GenKiMin2 TC EL</sub>
  <br>
  <img
    alt="GenKiMin2 TC L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tc%2BGenKiMin2%20TC%20L.png"
  >
  <br>
  <sub>GenKiMin2 TC L</sub>
  <br>
  <img
    alt="GenKiMin2 TC R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tc%2BGenKiMin2%20TC%20R.png"
  >
  <br>
  <sub>GenKiMin2 TC R</sub>
  <br>
  <img
    alt="GenKiMin2 TC M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tc%2BGenKiMin2%20TC%20M.png"
  >
  <br>
  <sub>GenKiMin2 TC M</sub>
  <br>
  <img
    alt="GenKiMin2 TC SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tc%2BGenKiMin2%20TC%20SB.png"
  >
  <br>
  <sub>GenKiMin2 TC SB</sub>
  <br>
  <img
    alt="GenKiMin2 TC B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tc%2BGenKiMin2%20TC%20B.png"
  >
  <br>
  <sub>GenKiMin2 TC B</sub>
  <br>
  <img
    alt="GenKiMin2 TC H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tc%2BGenKiMin2%20TC%20H.png"
  >
  <br>
  <sub>GenKiMin2 TC H</sub>
  <br>
</p>

- `buttaiwanPackages.genkimin2-tw` -
  [GenKiMin2 TW / 源起明體](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenKiMin2 TW EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tw%2BGenKiMin2%20TW%20EL.png"
  >
  <br>
  <sub>GenKiMin2 TW EL</sub>
  <br>
  <img
    alt="GenKiMin2 TW L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tw%2BGenKiMin2%20TW%20L.png"
  >
  <br>
  <sub>GenKiMin2 TW L</sub>
  <br>
  <img
    alt="GenKiMin2 TW R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tw%2BGenKiMin2%20TW%20R.png"
  >
  <br>
  <sub>GenKiMin2 TW R</sub>
  <br>
  <img
    alt="GenKiMin2 TW M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tw%2BGenKiMin2%20TW%20M.png"
  >
  <br>
  <sub>GenKiMin2 TW M</sub>
  <br>
  <img
    alt="GenKiMin2 TW SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tw%2BGenKiMin2%20TW%20SB.png"
  >
  <br>
  <sub>GenKiMin2 TW SB</sub>
  <br>
  <img
    alt="GenKiMin2 TW B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tw%2BGenKiMin2%20TW%20B.png"
  >
  <br>
  <sub>GenKiMin2 TW B</sub>
  <br>
  <img
    alt="GenKiMin2 TW H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genkimin2-tw%2BGenKiMin2%20TW%20H.png"
  >
  <br>
  <sub>GenKiMin2 TW H</sub>
  <br>
</p>

- `buttaiwanPackages.genyomin2-jp` -
  [GenYoMin2 JP / 源樣明朝](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenYoMin2 JP EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-jp%2BGenYoMin2%20JP%20EL.png"
  >
  <br>
  <sub>GenYoMin2 JP EL</sub>
  <br>
  <img
    alt="GenYoMin2 JP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-jp%2BGenYoMin2%20JP%20L.png"
  >
  <br>
  <sub>GenYoMin2 JP L</sub>
  <br>
  <img
    alt="GenYoMin2 JP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-jp%2BGenYoMin2%20JP%20R.png"
  >
  <br>
  <sub>GenYoMin2 JP R</sub>
  <br>
  <img
    alt="GenYoMin2 JP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-jp%2BGenYoMin2%20JP%20M.png"
  >
  <br>
  <sub>GenYoMin2 JP M</sub>
  <br>
  <img
    alt="GenYoMin2 JP SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-jp%2BGenYoMin2%20JP%20SB.png"
  >
  <br>
  <sub>GenYoMin2 JP SB</sub>
  <br>
  <img
    alt="GenYoMin2 JP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-jp%2BGenYoMin2%20JP%20B.png"
  >
  <br>
  <sub>GenYoMin2 JP B</sub>
  <br>
  <img
    alt="GenYoMin2 JP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-jp%2BGenYoMin2%20JP%20H.png"
  >
  <br>
  <sub>GenYoMin2 JP H</sub>
  <br>
</p>

- `buttaiwanPackages.genyomin2-pjp` -
  [GenYoMin2 PJP / 源樣明朝P](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenYoMin2 PJP EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-pjp%2BGenYoMin2%20PJP%20EL.png"
  >
  <br>
  <sub>GenYoMin2 PJP EL</sub>
  <br>
  <img
    alt="GenYoMin2 PJP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-pjp%2BGenYoMin2%20PJP%20L.png"
  >
  <br>
  <sub>GenYoMin2 PJP L</sub>
  <br>
  <img
    alt="GenYoMin2 PJP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-pjp%2BGenYoMin2%20PJP%20R.png"
  >
  <br>
  <sub>GenYoMin2 PJP R</sub>
  <br>
  <img
    alt="GenYoMin2 PJP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-pjp%2BGenYoMin2%20PJP%20M.png"
  >
  <br>
  <sub>GenYoMin2 PJP M</sub>
  <br>
  <img
    alt="GenYoMin2 PJP SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-pjp%2BGenYoMin2%20PJP%20SB.png"
  >
  <br>
  <sub>GenYoMin2 PJP SB</sub>
  <br>
  <img
    alt="GenYoMin2 PJP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-pjp%2BGenYoMin2%20PJP%20B.png"
  >
  <br>
  <sub>GenYoMin2 PJP B</sub>
  <br>
  <img
    alt="GenYoMin2 PJP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-pjp%2BGenYoMin2%20PJP%20H.png"
  >
  <br>
  <sub>GenYoMin2 PJP H</sub>
  <br>
</p>

- `buttaiwanPackages.genyomin2-tc` -
  [GenYoMin2 TC / 源樣明體丹](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenYoMin2 TC EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tc%2BGenYoMin2%20TC%20EL.png"
  >
  <br>
  <sub>GenYoMin2 TC EL</sub>
  <br>
  <img
    alt="GenYoMin2 TC L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tc%2BGenYoMin2%20TC%20L.png"
  >
  <br>
  <sub>GenYoMin2 TC L</sub>
  <br>
  <img
    alt="GenYoMin2 TC R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tc%2BGenYoMin2%20TC%20R.png"
  >
  <br>
  <sub>GenYoMin2 TC R</sub>
  <br>
  <img
    alt="GenYoMin2 TC M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tc%2BGenYoMin2%20TC%20M.png"
  >
  <br>
  <sub>GenYoMin2 TC M</sub>
  <br>
  <img
    alt="GenYoMin2 TC SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tc%2BGenYoMin2%20TC%20SB.png"
  >
  <br>
  <sub>GenYoMin2 TC SB</sub>
  <br>
  <img
    alt="GenYoMin2 TC B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tc%2BGenYoMin2%20TC%20B.png"
  >
  <br>
  <sub>GenYoMin2 TC B</sub>
  <br>
  <img
    alt="GenYoMin2 TC H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tc%2BGenYoMin2%20TC%20H.png"
  >
  <br>
  <sub>GenYoMin2 TC H</sub>
  <br>
</p>

- `buttaiwanPackages.genyomin2-tw` -
  [GenYoMin2 TW / 源樣明體](https://github.com/ButTaiwan/genyo-font)

<p align="center">
  <img
    alt="GenYoMin2 TW EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tw%2BGenYoMin2%20TW%20EL.png"
  >
  <br>
  <sub>GenYoMin2 TW EL</sub>
  <br>
  <img
    alt="GenYoMin2 TW L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tw%2BGenYoMin2%20TW%20L.png"
  >
  <br>
  <sub>GenYoMin2 TW L</sub>
  <br>
  <img
    alt="GenYoMin2 TW R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tw%2BGenYoMin2%20TW%20R.png"
  >
  <br>
  <sub>GenYoMin2 TW R</sub>
  <br>
  <img
    alt="GenYoMin2 TW M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tw%2BGenYoMin2%20TW%20M.png"
  >
  <br>
  <sub>GenYoMin2 TW M</sub>
  <br>
  <img
    alt="GenYoMin2 TW SB"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tw%2BGenYoMin2%20TW%20SB.png"
  >
  <br>
  <sub>GenYoMin2 TW SB</sub>
  <br>
  <img
    alt="GenYoMin2 TW B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tw%2BGenYoMin2%20TW%20B.png"
  >
  <br>
  <sub>GenYoMin2 TW B</sub>
  <br>
  <img
    alt="GenYoMin2 TW H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-genyomin2-tw%2BGenYoMin2%20TW%20H.png"
  >
  <br>
  <sub>GenYoMin2 TW H</sub>
  <br>
</p>

- `buttaiwanPackages.gensenrounded2-jp` -
  [GenSenRounded2 JP / 源泉丸ゴシック](https://github.com/ButTaiwan/gensen-font)

<p align="center">
  <img
    alt="GenSenRounded2 JP EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-jp%2BGenSenRounded2%20JP%20EL.png"
  >
  <br>
  <sub>GenSenRounded2 JP EL</sub>
  <br>
  <img
    alt="GenSenRounded2 JP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-jp%2BGenSenRounded2%20JP%20L.png"
  >
  <br>
  <sub>GenSenRounded2 JP L</sub>
  <br>
  <img
    alt="GenSenRounded2 JP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-jp%2BGenSenRounded2%20JP%20R.png"
  >
  <br>
  <sub>GenSenRounded2 JP R</sub>
  <br>
  <img
    alt="GenSenRounded2 JP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-jp%2BGenSenRounded2%20JP%20M.png"
  >
  <br>
  <sub>GenSenRounded2 JP M</sub>
  <br>
  <img
    alt="GenSenRounded2 JP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-jp%2BGenSenRounded2%20JP%20B.png"
  >
  <br>
  <sub>GenSenRounded2 JP B</sub>
  <br>
  <img
    alt="GenSenRounded2 JP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-jp%2BGenSenRounded2%20JP%20H.png"
  >
  <br>
  <sub>GenSenRounded2 JP H</sub>
  <br>
</p>

- `buttaiwanPackages.gensenrounded2-pjp` -
  [GenSenRounded2 PJP / 源泉丸ゴシックP](https://github.com/ButTaiwan/gensen-font)

<p align="center">
  <img
    alt="GenSenRounded2 PJP EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-pjp%2BGenSenRounded2%20PJP%20EL.png"
  >
  <br>
  <sub>GenSenRounded2 PJP EL</sub>
  <br>
  <img
    alt="GenSenRounded2 PJP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-pjp%2BGenSenRounded2%20PJP%20L.png"
  >
  <br>
  <sub>GenSenRounded2 PJP L</sub>
  <br>
  <img
    alt="GenSenRounded2 PJP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-pjp%2BGenSenRounded2%20PJP%20R.png"
  >
  <br>
  <sub>GenSenRounded2 PJP R</sub>
  <br>
  <img
    alt="GenSenRounded2 PJP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-pjp%2BGenSenRounded2%20PJP%20M.png"
  >
  <br>
  <sub>GenSenRounded2 PJP M</sub>
  <br>
  <img
    alt="GenSenRounded2 PJP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-pjp%2BGenSenRounded2%20PJP%20B.png"
  >
  <br>
  <sub>GenSenRounded2 PJP B</sub>
  <br>
  <img
    alt="GenSenRounded2 PJP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-pjp%2BGenSenRounded2%20PJP%20H.png"
  >
  <br>
  <sub>GenSenRounded2 PJP H</sub>
  <br>
</p>

- `buttaiwanPackages.gensenrounded2-tc` -
  [GenSenRounded2 TC / 源泉圓體丹](https://github.com/ButTaiwan/gensen-font)

<p align="center">
  <img
    alt="GenSenRounded2 TC EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tc%2BGenSenRounded2%20TC%20EL.png"
  >
  <br>
  <sub>GenSenRounded2 TC EL</sub>
  <br>
  <img
    alt="GenSenRounded2 TC L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tc%2BGenSenRounded2%20TC%20L.png"
  >
  <br>
  <sub>GenSenRounded2 TC L</sub>
  <br>
  <img
    alt="GenSenRounded2 TC R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tc%2BGenSenRounded2%20TC%20R.png"
  >
  <br>
  <sub>GenSenRounded2 TC R</sub>
  <br>
  <img
    alt="GenSenRounded2 TC M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tc%2BGenSenRounded2%20TC%20M.png"
  >
  <br>
  <sub>GenSenRounded2 TC M</sub>
  <br>
  <img
    alt="GenSenRounded2 TC B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tc%2BGenSenRounded2%20TC%20B.png"
  >
  <br>
  <sub>GenSenRounded2 TC B</sub>
  <br>
  <img
    alt="GenSenRounded2 TC H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tc%2BGenSenRounded2%20TC%20H.png"
  >
  <br>
  <sub>GenSenRounded2 TC H</sub>
  <br>
</p>

- `buttaiwanPackages.gensenrounded2-tw` -
  [GenSenRounded2 TW / 源泉圓體月](https://github.com/ButTaiwan/gensen-font)

<p align="center">
  <img
    alt="GenSenRounded2 TW EL"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tw%2BGenSenRounded2%20TW%20EL.png"
  >
  <br>
  <sub>GenSenRounded2 TW EL</sub>
  <br>
  <img
    alt="GenSenRounded2 TW L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tw%2BGenSenRounded2%20TW%20L.png"
  >
  <br>
  <sub>GenSenRounded2 TW L</sub>
  <br>
  <img
    alt="GenSenRounded2 TW R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tw%2BGenSenRounded2%20TW%20R.png"
  >
  <br>
  <sub>GenSenRounded2 TW R</sub>
  <br>
  <img
    alt="GenSenRounded2 TW M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tw%2BGenSenRounded2%20TW%20M.png"
  >
  <br>
  <sub>GenSenRounded2 TW M</sub>
  <br>
  <img
    alt="GenSenRounded2 TW B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tw%2BGenSenRounded2%20TW%20B.png"
  >
  <br>
  <sub>GenSenRounded2 TW B</sub>
  <br>
  <img
    alt="GenSenRounded2 TW H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensenrounded2-tw%2BGenSenRounded2%20TW%20H.png"
  >
  <br>
  <sub>GenSenRounded2 TW H</sub>
  <br>
</p>

- `buttaiwanPackages.gensekigothic2-jp` -
  [GenSekiGothic2 JP / 源石ゴシック](https://github.com/ButTaiwan/genseki-font)

<p align="center">
  <img
    alt="GenSekiGothic2 JP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-jp%2BGenSekiGothic2%20JP%20L.png"
  >
  <br>
  <sub>GenSekiGothic2 JP L</sub>
  <br>
  <img
    alt="GenSekiGothic2 JP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-jp%2BGenSekiGothic2%20JP%20R.png"
  >
  <br>
  <sub>GenSekiGothic2 JP R</sub>
  <br>
  <img
    alt="GenSekiGothic2 JP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-jp%2BGenSekiGothic2%20JP%20M.png"
  >
  <br>
  <sub>GenSekiGothic2 JP M</sub>
  <br>
  <img
    alt="GenSekiGothic2 JP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-jp%2BGenSekiGothic2%20JP%20B.png"
  >
  <br>
  <sub>GenSekiGothic2 JP B</sub>
  <br>
  <img
    alt="GenSekiGothic2 JP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-jp%2BGenSekiGothic2%20JP%20H.png"
  >
  <br>
  <sub>GenSekiGothic2 JP H</sub>
  <br>
</p>

- `buttaiwanPackages.gensekigothic2-pjp` -
  [GenSekiGothic2 PJP / 源石ゴシックP](https://github.com/ButTaiwan/genseki-font)

<p align="center">
  <img
    alt="GenSekiGothic2 PJP L"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-pjp%2BGenSekiGothic2%20PJP%20L.png"
  >
  <br>
  <sub>GenSekiGothic2 PJP L</sub>
  <br>
  <img
    alt="GenSekiGothic2 PJP R"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-pjp%2BGenSekiGothic2%20PJP%20R.png"
  >
  <br>
  <sub>GenSekiGothic2 PJP R</sub>
  <br>
  <img
    alt="GenSekiGothic2 PJP M"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-pjp%2BGenSekiGothic2%20PJP%20M.png"
  >
  <br>
  <sub>GenSekiGothic2 PJP M</sub>
  <br>
  <img
    alt="GenSekiGothic2 PJP B"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-pjp%2BGenSekiGothic2%20PJP%20B.png"
  >
  <br>
  <sub>GenSekiGothic2 PJP B</sub>
  <br>
  <img
    alt="GenSekiGothic2 PJP H"
    src="https://raw.githubusercontent.com/brsvh/chinese-fonts-overlay/font-preview-images/buttaiwan/buttaiwan-gensekigothic2-pjp%2BGenSekiGothic2%20PJP%20H.png"
  >
  <br>
  <sub>GenSekiGothic2 PJP H</sub>
  <br>
</p>

## AI 辅助声明

本项目中的部分代码、测试和文档是在 AI 工具的辅助下开发的。所有 AI 生成的内容均经过维护者的审查，并在必要时进行了修改。维护者对最终内容负全部责任。未向
AI 工具有意提供任何机密信息、用户隐私数据或其他敏感信息。

## 协议

除非特殊说明，您可以在 __Creative Commons Zero v1.0 Universal__
条款内做任何事。伴随源代码，您应当已收到了该协议的副本，如果没有，请访问
<https://creativecommons.org/publicdomain/zero/1.0/> 查看该协议的描述。

[^1]: https://www.foundertype.com/index.php/About/powerPer.html
[^2]: https://www.foundertype.com/index.php/About/powerbus.html
[^3]: http://cheonhyeong.com/Simplified/download.html
[^4]: https://tsanger.cn/%E4%BB%93%E8%80%B3%E5%AD%97%E5%BA%93%E5%85%8D%E8%B4%B9%E5%95%86%E7%94%A8%E5%AD%97%E4%BD%93%E6%8E%88%E6%9D%83%E5%A3%B0%E6%98%8E.pdf
