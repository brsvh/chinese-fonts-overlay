# 贡献指南

欢迎补充字体、修复打包问题或改进网站。人工和 agent 提交使用同一套流程：核对来源，完成与改动相关的检查，并写清结果。开始前请阅读
[维护约定](../AGENTS.md)。

## 报告问题

使用仓库的
[issue 模板](https://github.com/brsvh/chinese-fonts-overlay/issues/new/choose)。请求字体时提供发行方主页和已知许可；报告构建失败时提供完整包名、命令和相关日志。网站问题请附上页面地址、筛选条件及浏览器信息。

## 添加或更新字体

1. 查阅发行方主页、发行说明和原始许可，确认产品名称、版本及允许的用途。按独立家族、地区版本和许可决定是否拆包，保留同系列的字重、集合成员和可变实例。
2. 在 `packages/<字库>/<字体>/package.nix` 中维护包，参考同字库的现有定义。核对下载来源、hash
   和安装路径，并安装上游要求保留的许可证及版权说明。
3. 填写下述目录元数据。语言列表由工具扫描，其余内容依据上游资料和实际字形判断。
4. 构建目标包，检查安装结果；扫描语言覆盖，再生成该包的网站预览。最后运行格式和元数据检查。
5. 提交 PR，说明来源、许可依据、实际验证及未确认的部分。不要提交字体文件、扫描报告或生成的网站。

已有字库会自动发现新包。新增字库还需接入 `overlays/default.nix`、`flake.nix`，并在
`packages/font-metadata.nix` 中登记字库。聚合包由组合函数标记 `isFontAggregate`，不进入字体目录。

### 元数据

`meta.description` 简要介绍字体；需要详细说明时使用 `meta.longDescription`。`meta.homepage`
指向发行方主页，多个相关主页使用 URL 列表。`meta.license` 保存上游许可，`meta.redistributable`
表示是否允许再分发字体文件。免费下载或免费商用不足以确认再分发权限；无法确认时不要标为允许。

网站信息只维护在 `passthru.chinese-fonts-overlay-pages` 中。字段和合法取值由
[packages/font-metadata.nix](../packages/font-metadata.nix) 定义：

| 字段          | 要求                                                                               |
| ------------- | ---------------------------------------------------------------------------------- |
| `displayName` | 必填。发行方的家族或产品名称，优先采用其本地语言名称。                             |
| `vendor`      | 必填。已登记的字库标识。                                                           |
| `styles`      | 必填。非空、排序且不重复的风格列表。                                               |
| `languages`   | 必填。扫描得到的语言代码，排序且不重复；扫描结果可以为空。                         |
| `licenseCost` | 必填。`free`、`gratisPersonalUse`、`gratisCommercialUse` 或 `paid`。               |
| `embedding`   | 可选布尔值。省略时使用 `meta.redistributable`，两者缺失时为 `false`。              |
| `notices`     | 可选说明列表，每项包含 `level`、非空纯文本 `text`，以及可选的 HTTP(S) 来源 `url`。 |

名称不拼接同一家族的字重，不堆叠重复译名。分别打包的地区版、家族和可变版本应保留区别；一个包包含多个独立家族时，名称应能说明它们。

风格允许重叠：黑体通常同时标为 `hei` 和 `sans`，宋体通常同时标为 `serif` 和 `song`。圆体用 `rounded`，手写体用
`handwritten`，图标、表情及专用符号字体用 `symbol`。书法或装饰性手写体还可以有 `cal` 或
`art`，但不能将所有手写体都归入这两类。先参考上游说明，再检查相关款式和可变轴；不能只看名称或第一款字形。仍无法判断时请与维护者确认，`unknown`
必须单独使用。

费用分类沿用 `gpu` / `gcu` / `paid` 的约定：`gratisPersonalUse` 和 `gratisCommercialUse`
分别表示可免费获取个人或商业使用许可，`paid` 表示需付费购买，`free`
表示无许可费。它与许可证的自由软件属性是不同维度。分类不承诺所有用途均免费，例如个人屏显免费、打印收费仍可归为
`gratisPersonalUse`；适用范围和另行收费的用途写入 `notices`。

`embedding`
表示允许在软件、网页或设备中嵌入字体文件。生成图片、免费商用或仅允许嵌入文档，都不能单独证明此权限。需要另购、申请或尚未明确授予时，不标为允许。默认值正确时省略该字段；覆盖默认值或有特殊条件时，在
`notices` 中记录依据和来源。署名、源码提供、字体替换等许可条件仍须遵守。

`notices.level` 支持 `note`、`tip`、`important`、`warning` 和
`caution`。保留必要的限制与来源，避免重复解释通用许可。受限字体及其来源文件不得进入公开缓存或 PR 附件。

### 构建与扫描

在仓库根目录进入开发环境，新文件先用 `git add` 登记，以便 flake 读取：

```sh
nix develop
```

使用仓库锁定的 Nixpkgs 构建目标包：

```sh
nix build --impure --expr '
  let
    flake = builtins.getFlake ("git+file://" + toString ./.);
  in
  (import flake.inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = [ flake.overlays.default ];
  }).naverPackages.maru-buri
'
```

将 `naverPackages.maru-buri` 换成实际属性。检查 `result/share/fonts/`
中的格式、数量和变体，以及许可证是否安装。不要把 `pname` 或网站的 `vendor.package` 标识当作 overlay 属性名。

添加或修改字体文件后，更新语言覆盖并核对结果：

```sh
nix run .#update-font-languages -- naverPackages.maru-buri --write
nix run .#update-font-languages -- packages/naver/maru-buri/package.nix --check
```

命令接受多个完整属性名或 `package.nix` 路径，`--all` 选择全部包。省略 `--write` 和 `--check` 时仅输出报告；只有
`--write` 修改语言列表，`--check` 在记录过期时失败。工具先完成全部扫描，再准备修改，其他字段保持不变。`--source-root`
指定仓库，`--output` 将报告写入文件；报告含本地路径，不作为公开产物。

覆盖范围取各款字体的并集。工具保留 Fontconfig 识别结果，并在单款字体包含 U+3131–U+3163 的现代兼容字母和 U+AC00–U+D7A3
的全部现代韩文音节时补充韩语，不要求古韩文字母。覆盖扫描不保证塑形或地区字形正确，仍需查看预览。

### 检查预览

只构建本次涉及的字体：

```sh
nix develop .#pages
make -C pages PACKAGES=naverPackages.maru-buri
make -C pages serve
```

多个属性用空格分隔并加引号。打开本地页面后，按该字体支持的语言和风格调整筛选条件；默认筛选可能隐藏它。省略 `PACKAGES` 会构建全部字体，更多选项见
[网站说明](../pages/README)。

## 检查与 CI

提交前运行：

```sh
nix fmt --no-update-lock-file --no-write-lock-file -- --fail-on-change
nix flake check --no-update-lock-file --no-write-lock-file --print-build-logs
```

`nix flake check` 校验全部非聚合字体的元数据，包括 Windows
字体，不构建字体文件。它能发现缺字段、类型、取值及排序问题，不能证明名称、风格和许可判断正确，也不替代单包构建与语言扫描。

PR 的 `Flake checks` 检查格式、字体元数据、网站测试素材和完整的 HTML、Info 手册。`Package builds`
汇总字体构建与语言校验：构建可复用已验证记录；语言校验独立比较字体、语言列表及扫描工具，变化时重新扫描，不因构建命中缓存而跳过。Windows
字体需要本地来源，不自动构建或扫描，贡献者应提供本地验证结果。

网站修改运行 `nix develop .#pages -c make -C pages check`，界面修改还需在浏览器检查。维护工具和 CI
通过实际使用验证，不另建测试套件。纯文档修改核对命令、链接和排版即可。字体使用根目录的锁定依赖，开发工具使用
`tools/flake.lock`；更新依赖时请区分。

可信的默认分支流程只读取并校验 PR 构建记录，不执行 PR 代码。主线 Hercules CI
的字体构建、二进制缓存发布与网站发布独立运行，贡献者不需要调整发布凭据或配置。

## 提交与说明

按独立目的拆分提交。独立字体的新增或版本更新逐包提交；同一目的的元数据整理可以合并。提交信息使用英文 `scope: Verb summary`，正文以
`* path: Change.` 按路径列出改动。字体新增和升级使用 `<pname>: Init at <版本>` 或
`<pname>: Update to <版本>`，详见 [提交约定](../.agents/skills/commit/SKILL.md)。

仓库提供一个自动载入的 PR 模板。说明问题、影响和实际验证即可，不必记录尝试过程；不适用的部分可以删除。使用 AI 辅助时，提交者仍需核对来源和结果。

项目说明使用中文，默认 `README` 使用 Org 格式。社区文件保留 GitHub 支持的格式，技能与 `AGENTS.md` 可使用英文
Markdown。写清当前用法和稳定约定，不记录会话经过或部署状态。
