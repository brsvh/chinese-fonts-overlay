# 贡献指南

欢迎为本项目补充新字体、更新已有字体包、修复打包问题，或改进使用手册与预览网站。如果你只是打算安装和使用字体，请先浏览[字体预览网站](https://brsvh.org/chinese-fonts-overlay/)并查阅[在线使用手册](https://brsvh.org/chinese-fonts-overlay/manual/)。

## 报告问题与提交字体请求

提交反馈前，建议先在[字体预览网站](https://brsvh.org/chinese-fonts-overlay/)确认目标字体是否已经收录，并在[在线使用手册](https://brsvh.org/chinese-fonts-overlay/manual/)查看是否已有对应的配置或排查说明。

请通过仓库的[问题模板](https://github.com/brsvh/chinese-fonts-overlay/issues/new/choose)提交反馈：

- **请求新字体**：提供字体正式名称、发行方、官方主页或发布地址，以及已知的许可证信息。
- **报告构建或打包问题**：附上完整包属性（例如
  `naverPackages.maru-buri`）、执行的命令、系统架构与关键错误日志，不要在附件中上传受限字体文件。
- **反馈网站或手册问题**：说明页面地址、当时的筛选条件以及浏览器版本。

## 仓库结构

动手修改前，可以先了解仓库中各目录的职责：

- `packages/`：按字库存放字体包定义，以及共享的元数据校验与目录提取规则（[packages/font-metadata.nix](../packages/font-metadata.nix)）。
- `overlays/`：默认 overlay 与各字库合集的定义。
- `lib/`：供 overlay 与 flake 使用的辅助函数及自定义许可证定义。
- `pages/`：[字体预览网站](https://brsvh.org/chinese-fonts-overlay/)与使用手册源码，手册章节位于
  `pages/doc/`，本地开发说明见[网站与手册开发说明](../pages/README)。
- `tools/`：语言覆盖扫描工具、开发环境与代码格式化配置。

仓库使用两份锁文件：根目录的 `flake.lock` 锁定字体包构建所用的 Nixpkgs，而 `tools/flake.lock`
锁定开发工具、格式化工具与网站构建环境。更新依赖时请区分两者，不要在字体改动中顺带修改无关的锁文件。

## 添加或更新字体

维护字体包的基本流程如下：

1. **核对上游信息**：查阅发行方主页、发行说明和原始许可证，确认产品名称、版本号与允许的使用范围。按独立家族、地区版本和许可证决定是否拆包；同一家族的不同字重、字体集合成员与可变字体实例应保留在同一个包中。
2. **编写或更新包定义**：在 `packages/<字库>/<字体>/package.nix`
   中维护包定义，风格与安装结构可参考同字库的现有包。核对下载地址、hash 和安装路径，并安装上游要求随附的许可证与版权声明文件。
3. **填写目录元数据**：补齐 `meta` 与 `passthru.chinese-fonts-overlay-pages`
   字段。语言列表由扫描工具生成，其余字段依据上游资料与实际字形判断。
4. **本地验证**：构建目标字体包并检查安装内容，运行语言覆盖扫描，再本地构建该包的预览页面核对显示效果。
5. **格式检查与提交**：运行格式化与元数据检查后提交
   PR，说明上游来源、许可依据、实际验证项以及尚待确认的细节。不要提交字体文件、本地扫描报告或生成的网站目录。

对于已有字库，`overlays/default.nix` 会自动发现该字库目录下新增的包。如果是新增字库，还需要同步更新三处：

- 在 [overlays/default.nix](../overlays/default.nix) 中注册字库包集合与合集；
- 在 [flake.nix](../flake.nix) 中导出对应的字库合集；
- 在 [packages/font-metadata.nix](../packages/font-metadata.nix) 的 `vendors`
  中登记字库标识与显示名称。

由组合函数生成的合集包带有 `isFontAggregate = true` 标记，不会作为单款字体进入目录与预览列表。

### 元数据与许可判断

标准 `meta` 字段用于记录上游基本信息：`meta.description` 写明字体简介，需要进一步说明时补充
`meta.longDescription`；`meta.homepage` 填写发行方主页（有多个相关主页时使用 URL 列表）；`meta.license`
记录上游许可；`meta.redistributable` 表示上游是否允许再分发字体文件。

预览网站与使用手册展示的目录信息统一维护在 `passthru.chinese-fonts-overlay-pages` 中，合法字段与取值由
[packages/font-metadata.nix](../packages/font-metadata.nix) 校验：

| 字段          | 要求                                                                            |
| ------------- | ------------------------------------------------------------------------------- |
| `displayName` | 必填。发行方使用的家族或产品名称，优先采用其本地语言名称。                      |
| `vendor`      | 必填。已在 `packages/font-metadata.nix` 中登记的字库标识。                      |
| `styles`      | 必填。非空、按字母排序且不重复的风格标识列表。                                  |
| `languages`   | 必填。由工具扫描得到的语言代码，按字母排序且不重复；结果可以为空。              |
| `licenseCost` | 必填。取值为 `free`、`gratisPersonalUse`、`gratisCommercialUse` 或 `paid`。     |
| `embedding`   | 可选布尔值。省略时沿用 `meta.redistributable`，两者均缺失时为 `false`。         |
| `notices`     | 可选说明列表。每项包含 `level`、非空纯文本 `text` 及可选的 HTTP(S) 来源 `url`。 |

填写这些字段时，请注意以下判断标准：

- **展示名称**：不要把同一家族的字重名称拼进
  `displayName`，也不要堆叠重复译名。如果地区版、独立家族或可变版本是分开打包的，名称中应保留清晰区别；单个包内含多个独立家族时，名称应能概括它们。
- **风格分类**：风格允许重叠，例如黑体通常同时标注 `hei` 和 `sans`，宋体通常同时标注 `serif` 和 `song`；等宽字体使用
  `mono`，与 `sans`、`serif` 一样可与黑体、宋体、楷体、仿宋、圆体或手写体等并存。除编程或标明等宽的字体外，半角 ASCII /
  拉丁字符具有统一进宽、与全角汉字成固定宽度比的双宽 CJK 字体（例如中易宋体、新晰黑体等）也应标注
  `mono`；若包内包含等宽款式同样需要标注，但不要仅凭字体表中的等宽标志或缺少拉丁字符的纯汉字补字面误判。圆体使用 `rounded`，手写体使用
  `handwritten`，图标、表情及专用符号字体使用 `symbol`。书法风格或装饰性手写体可以额外加上 `cal` 或
  `art`，但不要把所有手写体都归入这两类。判断风格时应先看上游说明，再检查包内所有相关款式与可变轴，不要仅凭字体名称或第一款字形下结论。确实无法归类时可在
  PR 中说明，由维护者一同确认；`unknown` 必须单独使用，不能与其他风格并列。
- **许可费用、再分发与嵌入权限**：判断字体许可时，请将**许可费用**、**软件自由属性**、**再分发权限**与**嵌入式使用**分开核对，不要互相推演。免费下载不等于免费商用，免费商用也不代表上游允许把字体文件再分发给他人；在未查到明确授权依据前，宁可保守标注，也不要把
  `meta.redistributable` 设为允许。
- **费用分级**：`licenseCost` 与软件自由属性是两个维度。`free` 表示无许可费，`gratisPersonalUse` 和
  `gratisCommercialUse` 分别表示可免费获取个人或商业使用许可，`paid`
  表示需付费购买。归入某一免费级别并不承诺所有使用场景都免费——例如个人屏显免费但印刷收费，仍可标为
  `gratisPersonalUse`，并把适用范围和另行收费的场景写进 `notices`。
- **嵌入式使用**：`embedding`
  对应[字体预览网站](https://brsvh.org/chinese-fonts-overlay/)中的“嵌入式使用”筛选条件，指上游明确允许将字体文件附带在软件、网页或硬件设备中分发。将文字栅格化为图片、仅在
  PDF 等文档中嵌入子集，或允许免费商业设计，都不足以证明具备该权限。当默认规则（沿用 `meta.redistributable`，缺失时为
  `false`）已经符合上游条款时，直接省略该字段；需要显式覆盖或存在附加条件时，请把依据和原文链接一并写入 `notices`。
- **注意事项**：`notices.level` 支持 `note`、`tip`、`important`、`warning` 和
  `caution`。只记录确有必要提醒用户的限制、特殊授权条件与原文链接，不必重复解释常见开源许可证的通用条款。受限字体文件及其私有来源不得进入公开二进制缓存或
  PR 附件。

### 本地构建与语言扫描

在仓库根目录进入默认开发环境。如果你新建了文件，请先执行 `git add` 将其加入暂存区，否则 Nix flake 无法读取未追踪的文件：

```sh
nix develop
```

使用仓库锁定的 Nixpkgs 构建目标字体包（将 `naverPackages.maru-buri` 替换为实际包属性）：

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

构建完成后，检查 `result/share/fonts/`
中的字体格式、文件数量、字重或变体是否与上游一致，并确认上游要求的许可证与版权文件已正确安装。请注意使用完整的 overlay 属性名（如
`naverPackages.maru-buri`），不要把 `pname` 或网站的 `vendor.package` 标识当作属性名。

新增字体或更新字体文件后，运行扫描工具更新并校验 `languages` 字段：

```sh
nix run .#update-font-languages -- naverPackages.maru-buri --write
nix run .#update-font-languages -- packages/naver/maru-buri/package.nix --check
```

工具支持同时传入多个完整包属性或 `package.nix` 路径，也支持 `--all` 扫描全部字体包。不加 `--write` 与 `--check`
时，工具只向标准输出打印 JSON 报告而不改动文件；`--write` 会先完成全部扫描，再只更新语言列表并保持其他字段原样；`--check`
会在记录过时时返回失败。另可通过 `--source-root` 指定仓库目录，或用 `--output`
将报告写入本地文件（报告包含本地存储路径，请勿提交或公开）。

包的语言覆盖是其所含全部字体的并集。扫描工具保留 Fontconfig 的识别结果及 CJK 地区隔离规则（`exclusiveLang`），并仅对
Fontconfig 正字表中两类非必要码位作逐字体豁免：

- **简体中文**：单款字体缺少 `U+02C7`（`ˇ`）或 `U+02C9`（`ˉ`），但已完整覆盖 Fontconfig `zh-cn`
  正字表的其余全部 GB 2312-80 汉字时，补充 `zh-sg`；若 `exclusiveLang` 未排除简体中文，同时补充 `zh-cn`。
- **韩文**：单款字体缺少古韩文兼容字母（`U+3165`–`U+318E`），但已完整覆盖 Fontconfig `ko` 正字表的其余全部码位且
  `exclusiveLang` 未排除韩文时，补充 `ko`。

语言覆盖只反映字形存在与否，不能保证塑形或地区字形一定正确，因此仍需结合预览页面检查。

### 本地检查字体预览

为了加快本地验证，只构建本次改动涉及的字体包：

```sh
nix develop .#pages
make -C pages PACKAGES=naverPackages.maru-buri
make -C pages serve
```

需要同时预览多个包时，将多个完整属性名用空格分隔并加引号。打开本地页面后，请根据目标字体支持的语言、风格与许可调整左侧筛选条件，因为默认筛选（简体中文、无衬线体、开源许可）可能会暂时隐藏该字体。

省略 `PACKAGES`
会构建全部字体包，耗时较长。关于缓存目录、独立构建目录与手册预览的更多用法，见[网站与手册开发说明](../pages/README)。

## 提交前检查与 CI

提交改动前，在仓库根目录运行格式与元数据检查：

```sh
nix fmt --no-update-lock-file --no-write-lock-file -- --fail-on-change
nix flake check --no-update-lock-file --no-write-lock-file --print-build-logs
```

`nix flake check` 会校验所有非聚合字体包的元数据（包括 Windows
字体），且不会实际下载或构建字体文件。它能拦截缺字段、类型错误、非法取值与排序问题，但不能代替人工核对名称、风格与许可依据，也不能代替单包构建和语言扫描。

如果你的改动涉及其他范围，请按需补充对应检查：

- **网站代码或样文数据**：运行
  `nix develop .#pages -c make -C pages check`，涉及界面布局或交互时在浏览器中实际检查。
- **使用手册**：运行 `nix develop .#manual -c make -C pages check-manual`，核对 HTML
  链接、节点覆盖与 Info 输出。
- **纯文档改动**：核对文中的命令、路径、链接和排版宽度即可，无需构建字体包。

提交 PR 后，GitHub Actions 会自动运行两组检查：

- **Flake checks**：检查代码格式、全量字体元数据、网站测试素材以及完整的 HTML 和 Info 手册。
- **Package
  builds**：针对受影响的字体包执行构建与语言覆盖校验。构建阶段会复用已验证的结果；语言校验会独立比对字体推导、已记录语言和扫描工具，只要三者之一有变化就会重新扫描。Windows
  字体依赖本地镜像来源，无法在 CI 中自动构建或扫描，修改时请在 PR 中附上本地验证结果。

## 提交信息与 PR 说明

请按独立目的拆分提交。新增一款字体或升级一个包的版本，应单独作为一个提交；属于同一整理目标的批量元数据修正可以合并提交。

提交信息使用英文 GNU 风格，由一行标题、一个空行和按文件路径排列的正文条目组成：

- **标题格式**：使用 `<scope>: <Verb> <summary>` 或
  `<scope>: <subscope>: <Verb> <summary>`。scope 使用小写字母，动词使用首字母大写的祈使语气，末尾不加句号。
- **新增或更新单个字体包**：scope 使用该包的 `pname`，标题固定为 `<pname>: Init at <版本>` 或
  `<pname>: Update to <版本>`。
- **正文格式**：每个改动文件一行，写作 `* <path>: <Change>.`，按路径字典序排列，首字母大写并以句号结尾；单行不超过 70
  列，折行时从第 0 列顶格继续，不重复 `* <path>:`。

例如，更新单个字体包时：

```text
naver-maru-buri: Update to 1.00

* packages/naver/maru-buri/package.nix: Update version, hash, and
scanned language list.
```

修改文档或工具代码时：

```text
doc: Rewrite contributor guide

* .github/CONTRIBUTING.md: Clarify metadata, commit rules, and local
verification workflow.
```

发起 PR 时会自动载入 PR 模板。请如实填写改动目的、上游来源、许可判断依据以及实际运行过的检查项；模板中不适用的小节可以直接删除。

仓库文档统一使用中文。根目录与子目录的默认 `README` 使用 Org 格式（首行声明 Emacs Org 模式文件局部变量，写法见根目录
[README](../README) 首行；源码行宽不超过 80 显示列，中英文及行内标记之间保留空格）；`.github/` 下的社区文档使用 GitHub
支持的 Markdown 格式；面向最终用户的完整说明统一写在 `pages/doc/` 使用手册中，不在各个字体包目录下单独添加 README。
