# 开发文档

本文档说明如何修改字体包、验证构建和维护预览图。issue、PR 模板和提交组织方式见 [贡献指南](CONTRIBUTING.md)。项目 README 位于
`docs/README.md`。

## 仓库结构

- `packages/<vendor>/<font>/package.nix`：字体包定义。
- `overlays/default.nix`：组织 vendor scope，并定义聚合包。
- `flake.nix`、`flake.lock`：公开 overlay、聚合包和字体构建使用的锁定输入。
- `lib/licenses.nix`：本仓库自定义许可证。
- `tools/dev-shells/default.nix`：开发环境、格式化配置和提交前检查。
- `tools/flake.nix`、`tools/flake.lock`：开发工具和 CI 依赖使用的独立输入。
- `tools/generate-font-preview-images/`：预览生成器和 `sample-keys.nix` 样本配置。
- `ci/`：字体选择、构建记录、预览发布和 Hercules CI 任务。
- `site/`：使用 Guile Hoot 的本地字体预览网站。
- `.github/workflows/`：PR 的格式检查、字体构建和预览发布工作流。
- `.agents/skills/`：打包、预览、Nix 风格和提交规范。

已有 vendor scope 会从包目录发现新包。新增 vendor 时，还需要接入 overlay、flake 聚合包、预览样本分组和 README；例如
LXGW 使用 `packages/lxgw/`、`lxgwPackages` 和 `lxgw-fonts`。

## 开发环境

从仓库根目录进入默认开发环境：

```console
$ nix develop
```

该环境提供 Git、treefmt、nixfmt、mdformat、Biome、clang-format、mbake 和
prek，并安装提交前格式检查。需要字体预览工具时，使用 `nix develop .#generator`。

进入环境会生成 `.bake.toml`、`.clang-format`、`.editorconfig`、`prek.toml` 和
`treefmt.toml` 的符号链接。这些文件不提交到仓库；修改配置时应编辑
`tools/dev-shells/default.nix`。开发工具与字体包使用不同的锁定输入，更新依赖时请确认修改的是根目录还是 `tools/`
下的锁文件。

`.clang-format` 使用 GNU 预设。clang-format 是可选工具，不加入 treefmt 或提交检查；可以手动运行
`clang-format --style=file -i site/src/font-info.c`，并检查格式化差异。

Makefile 格式化使用 bake 项目的 `mbake`。手写的 Makefile、`*.mk` 和 `Makefile.am` 最多 80
列，命令行前缀保留 Tab。从仓库根目录按需运行：

```console
$ mbake format --config .bake.toml site/Makefile.am
$ mbake format --config .bake.toml --check site/Makefile.am
$ editorconfig-checker -disable-indentation site/Makefile.am
```

当前锁定的 mbake 不会根据 `max_line_length` 自动拆行或报告超长行，行宽由 EditorConfig 检查；超长内容需在保持 Make
和 shell 语义的前提下手动续行。缩进交给 mbake 检查，避免将合法的变量续行空格误报为缺少 Tab。 这里只提供开发工具，不加入 treefmt
或提交检查。 不要格式化生成的 `Makefile.in` 或配置后的 Makefile；`Makefile.am` 的语法仍通过 Automake
和构建检查验证。

## 本地网站原型

网站位于 `site/`，通过 `site/default.nix` 注册到根 flake 的 `private.modules`， 复用
`tools/flake.lock` 中的开发依赖。

在仓库根目录启动：

```console
$ nix run .#site
$ nix run .#site -- --port 8080
```

默认地址为 <http://127.0.0.1:8000>，服务仅监听本机。按 Ctrl-C 停止服务。 Nix 使用同一套 Autotools 构建
Guile 命令、C 工具及 Hoot 浏览器资源；启动时生成目录和透明预览到 `site/dist/`。
修改源码后重新启动并刷新浏览器。生成的文件不提交到仓库。

只生成静态文件或查看参数：

```console
$ nix run .#site -- --build
$ nix run .#site -- --help
```

也可以进入 `nix develop .#site` 直接使用 `font-site`，或构建当前工作区中的源码：

```console
$ nix develop .#site
$ cd site
$ ./bootstrap
$ mkdir -p build
$ cd build
$ ../configure
$ make
$ make check
$ make site
$ make serve PORT=8080
```

`make` 只编译 C 工具和 Hoot 资源；`make check` 使用小型测试字体，不下载完整字库。 `make site` 生成
`build/public/`，`make serve` 生成并提供该目录，缓存位于 `build/cache/`。 可以通过
`OUTPUT`、`CACHE`、`PORT` 覆盖这些路径和端口。`font-site` 默认仍使用仓库的 `site/dist/` 和
`site/.cache/`。 `font-site --serve-only --output DIR --port 8080` 可直接提供已有静态目录。

源码按照 GNU Autotools 子项目组织：`module/chinese-fonts-overlay-site/` 为原生 Guile
模块，`scripts/` 为命令入口， `src/` 为 C 字体工具，`web/` 为 Hoot、HTML 和必要的浏览器绑定，`data/`
为语言映射，`tests/` 为 SRFI-64 检查。 维护 `configure.ac` 和
`Makefile.am`；`configure`、`Makefile.in` 等文件由 `bootstrap` 生成，不提交。
`make distcheck` 验证源码发行包的完整构建流程。发行包包含生成的 `configure`，无需 Git 即可编译。 Automake 使用
`foreign` 模式；`site/README` 是 Org 格式的极简简介和本地启动入口。

Nix 只供应依赖和目录输入，不复制构建逻辑。进入开发环境和查看帮助不实现全部字体；完整网站生成才按需实现私有字体输入。 脱离 Nix 构建时需要 Guile
3、guile-json、guile-gcrypt、Hoot、C 编译器、pkg-config、FreeType、Fontconfig、Pango 和
Cairo。 生成网站另外需要显式传入 `CATALOG` 和 `PREVIEWS` JSON；没有 Git 检出时传入完整的
`SOURCE_REVISION`，或使用命令的 `--revision`。

字体目录由 `site/catalog.nix` 从根 flake 锁定的 nixpkgs 和 overlay 中读取包元数据，目录求值不下载或构建字体。
网站仅枚举具有 `package.nix` 的字体包，并排除声明 `passthru.isFontAggregate = true` 的聚合包。 例如
`windows-fonts` 总包不进入网站目录、搜索、筛选或预览清单，各个独立的 Microsoft 字体包照常展示。 overlay
的组合函数也统一设置此标记；新增同类总包时应在包定义中声明。多字重、TTC 集合及字体自身的分区文件不因此排除。
`site/module/chinese-fonts-overlay-site/catalog.scm` 将目录生成为静态 HTML 和
`site/dist/catalog.json`，包含包名、Nix 属性、版本、字库、描述、 许可证费用、许可名称及链接、`redistributable` 和
`package.nix` 路径。单个许可和许可列表统一导出为数组；缺失的再分发标记按 `false` 处理， 不从许可的自由性推导再分发权限。

页面将 Nix 属性标为“包名”，将 `redistributable` 直接显示为“再分发：允许／不允许”，不会另行推导许可权限。
字重／款式名称从实际字体文件读取， 包含集合中的每个成员与可变字体的命名款式，全部展开显示，并写入 JSON 的 `faces`
数组；`facesSource` 记录来源。

目录支持按包名、字库、款式、描述或许可搜索，并按字库、许可证费用、许可证、再分发、语言和风格组合筛选。筛选逻辑由 Hoot 运行。 每个包的分类直接维护在
`package.nix` 的 `passthru.fontInfo` 中：

```nix
passthru = {
  fontInfo = {
    languages = [
      "bo"
      "dz"
    ];

    licenseCost = "commercialFree";

    styles = [
      "sans"
    ];

    vendor = "xiaomi";
  };
};
```

以上是 [MiSans Tibetan](../packages/xiaomi/misans-tibetan/package.nix) 的分类示例。 新增包的
`vendor` 必须使用登记的标识，`languages` 必须以扫描结果为准。 这些字段不参与字体派生的构建，也不会仅因分类调整而重新构建字体。 网站导出
schema 4 的目录；分类数据只有包定义这一份，公共的 `lib/font-info.nix` 保存词汇、显示名称和校验规则。
缺字段、未登记的风格或字库、非法语言代码及重复／未排序列表都会使目录求值失败。

`fontInfo.notices` 是可选的注意事项列表，省略或设为 `[ ]` 时，网站不显示“注意事项”区块。
每个字体包独立维护自己的列表；网站直接显示该包的内容，不按字库、系列或款式推导范围，也不自动继承其他包的提醒。
注意事项默认展开，位于样本之前。若只涉及包内部分款式，应在正文中明确列出款式或文件名。

```nix
notices = [
  {
    level = "caution";

    text = ''
      文鼎科技与王漢宗字型存在纠纷，应当避免商业使用如下字体：

      - HanWangLiSuMedium，王漢宗中隸書繁，wt021.ttf
    '';
  }
];
```

每条必须包含 `level` 和非空 `text`，可选 `url` 提供 HTTP(S) 参考链接。 `level` 支持
`note`（说明）、`tip`（提示）、`important`（重要）、`warning`（警告）、`caution`（警示）， 显示名称统一登记在
`lib/font-info.nix` 的 `noticeLevels` 中。 `text` 为纯文本，保留换行并进行 HTML 转义；不解析 Markdown
或 HTML。列表保留维护者指定的顺序。 目录 JSON 始终导出 `notices` 数组，每项保留级别、正文、可选链接，并补充中文 `levelName`。
新增提醒或调整内容只需修改对应的 `package.nix`；修改 README 不会自动改写网站内容。

- `vendor`：字库或发行项目的稳定标识。显示名称登记在 `lib/font-info.nix` 的 `vendors` 中，
  不从目录名或版本推导，也不表示版权归属或原始设计者。例如 Windows 附带字体归入 Microsoft 字库。 JSON 保留 `vendor`
  标识，并提供 `vendorName` 显示名称及完整 `vendors` 词汇表。
- `styles`：人工审核的风格列表。可选 `kai`（楷体）、`song`（宋体）、`hei`（黑体）、`fangsong`（仿宋）、
  `serif`（衬线体）、`sans`（无衬线体）、`li`（隶书）、`cal`（书法字体）、`art`（艺术字体）、`unknown`（未知）。
  中文黑体同时标记 `hei` 与 `sans`，宋体同时标记 `serif` 与 `song`；手写／毛笔风格使用 `cal`，装饰、卡通和图案字体使用
  `art`。 混合风格和合集可以标记多个类型。优先查上游主页介绍，再核对实际预览；依据不足时明确填写 `[ "unknown" ]`。 `unknown`
  是可筛选的风格，不能与已知风格混用。自动语言扫描不会改写风格。
- `languages`：从字体实际字符覆盖推断的语言代码列表，按代码排序、去重。包内全部文件、字重及合集成员的语言取并集，
  因而某语言不一定适用于包内每款字体。空列表表示未匹配到已知语言（例如纯符号字体），页面显示“未知”。
  页面只显示简体中文语言名称，不附加语言代码；代码仍用于数据记录和筛选。
  中文地区名称使用“简体中文（中国大陆）”“简体中文（香港）”“简体中文（新加坡）”“繁体中文（澳门）”“繁体中文（台湾）”。 名称在
  `site/data/language-names.json` 中维护，沿用原有 Babel/CLDR 简体中文名称和项目补充译名；运行时无需 Babel。
  遇到没有译名的新代码时构建报错，补充名称后即可继续，不在页面显示原始代码。
- `licenseCost`：人工核对上游授权后填写的费用分类。可选 `none`（无）、`commercialFree`（商业免费使用）、
  `personalFree`（个人免费使用）、`paid`（付费使用）。OFL、GPL、IPA、M+ 等自由／开源许可证归入 `none`；
  免费商用的专有许可证归入 `commercialFree`； 个人非商业使用免费、商用收费或不允许商用的字体归入
  `personalFree`；正式使用需购买授权或随付费产品提供的字体归入 `paid`。
  分类只概括费用及使用范围，具体条件由单独的“许可证”名称和链接提供，不根据 `free = false` 或 `redistributable` 推导。
  JSON 导出 `licenseCost`、`licenseCostName` 和
  `licenseCostLabels`；许可证数组保留协议标识、名称、链接及原有自由性信息。
  例如依据[方正的免费商用说明](https://www.foundertype.com/index.php/Index/plusHelp.html)，黑体、书宋、仿宋、楷体归入商业免费使用；
  仓耳的六套免费字体参考[免费授权声明](https://www.tsanger.cn/107.html)，其余按包内已有个人非商业使用说明分类。
  天珩依据[上游下载说明](http://cheonhyeong.com/Simplified/download.html)归入个人免费使用，保留原有字形版权说明；
  方正隶书、细黑一、细圆、准圆、粗圆、小标宋依据[官方注册说明](https://nzj.foundertype.com/register.html)
  和[字体授权说明](https://www.foundertype.com/index.php/About/powerbus.html)归入
  `paid`：普通用户家庭版及发布使用需购买授权； 职业设计师个人非商业免费试用的条件单独写入各包的
  `notices`，不把受限试用当作普遍的个人免费使用许可。 Windows
  随附字体归入付费使用，具体范围参考[微软字体使用说明](https://learn.microsoft.com/en-us/typography/fonts/font-faq)。

网站的样文独立于字体包，统一在 `site/data/language-samples.json` 中按语言代码维护。包定义不再包含 `sampleKey`。
CI 继续读取原有 `tools/generate-font-preview-images/sample-keys.nix`，该表及其读取流程保留不动。

添加字体或更新字体文件后，在 site 开发环境中重新扫描所选包：

```console
$ nix develop .#site -c font-site update-font-info --package naver.maru-buri --write --output /tmp/maru-buri-coverage.json
$ nix develop .#site -c font-site update-font-info --package naver.maru-buri --check --output /tmp/maru-buri-coverage.json
```

`--package` 可重复指定，`--all` 扫描所有包；省略 `--write` / `--check` 时只生成报告。 工具使用根 flake 锁定的
nixpkgs 与 overlay，按需构建字体，再用开发环境中的 Fontconfig 扫描 OTF、TTF、OTC 和 TTC，
包括集合成员与可变字体实例。扫描时屏蔽用户的 Fontconfig 配置，报告记录扫描器版本及每个文件、款式的语言明细。
所有选定包扫描成功后，`--write` 只替换对应包的 `languages` 字面量列表；`vendor`、`styles`、`licenseCost`
仍由维护者审核。 `--check` 在记录过期时返回非零状态；普通网站构建不会改写 `languages`，预览生成仍读取字体文件检查样文字形。 升级锁定的
Fontconfig 后，也应重新扫描并审查语言列表变化。

[Fontconfig](https://fontconfig.pages.freedesktop.org/fontconfig/fontconfig-user.html)
根据 Unicode 字符覆盖与语言字表推断语言，不验证复杂文字塑形、排版质量或地区字形偏好。
因此该字段表示字符覆盖匹配结果，并非完整语言支持承诺；少量罕见文字也可能因 Fontconfig 没有相应字表而无法识别。
扫描报告可能包含受限字体的本地文件信息，报告不作为网站资源发布。网站只发布透明样本图片和公开索引。

每个 `source` 链接打开 GitHub 上对应 `package.nix` 的永久网页链接。构建时读取当前检出的完整 `HEAD` 提交 SHA，
与包路径组合为
`https://github.com/brsvh/chinese-fonts-overlay/blob/<commit>/packages/<vendor>/<name>/package.nix`。
仓库地址集中维护在 `site/module/chinese-fonts-overlay-site/catalog.scm` 的
`source-repository`；JSON 同时记录 `sourceRepository` 和 `sourceRevision`，每个包仍包含
`source.path` 与 `source.url`。构建无需联网，源码链接直接指向 GitHub。 这采用
[GitHub 的永久链接格式](https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files)，
不受后续分支移动影响。普通检出、浅克隆和 detached HEAD 都使用检出的提交，无需获取完整 Git 历史。

本地未提交的修改可以参与目录预览，但永久链接指向 `HEAD` 中的已提交版本，不包含这些修改；新增包须提交并推送到上述 GitHub 仓库后，
相应链接才可访问。发布网站时应从已推送的干净检出构建，使目录与链接中的源码一致。 修改包元数据后重新运行 `nix run .#site`；若使用开发
shell 中的 `make`，需重新进入 `nix develop .#site` 刷新目录输入。

页面未添加视觉样式。字体目录和 GitHub 源码链接在 JavaScript 或 Hoot 不可用时仍可使用，筛选输入保持禁用并显示提示。
所有字体统一显示固定样本，背景透明，不提供试字输入。包的详细说明直接展开显示。

### 完整字体预览

`site/previews.nix` 根据目录自动枚举全部字体包，不维护代表包名单。首次完整构建需要实现所有字体包输出， 私有清单中的
`renderPath` 仅供本地解析与图片生成。无论 `redistributable` 是否允许再分发，网站均只导出透明 PNG，
不复制字体或字符覆盖文件。再分发仍按包的许可元数据显示。构建完成后 `site/dist/` 可以独立放到静态 HTTP 服务器， 不依赖 Nix store
或运行中的后端。

款式从名称表和可变字体的 `fvar` 表读取，保留所有字重、TTC/OTC 集合成员和可变字体的命名实例。 渲染使用原始
OTF/TTF/TTC/OTC，直接选择文件成员与变体坐标，不转换或抽取字体。相同文件、集合成员与变体坐标可跨包复用图片。

现有语言筛选框同时筛选字体包并选择对应的样本图片。没有 URL 语言参数时默认选中“中文”，匹配中文各地区及中文语言标签，
优先显示简体样文，缺少简体字形时使用已配置的繁体或罕见汉字样文。选择具体中文地区时使用该地区的映射。
“全部语言”显示每款字体的默认可用样本；清除筛选恢复默认中文。URL 的 `language=` 表示明确选择全部语言，
与不带该参数的默认中文区分。完整语言覆盖仍显示在包详情中；筛选依据仍是包内款式语言覆盖的并集。
某款式不支持所选语言的样文时，保留款式名称并提示暂无该语言样本，不用其他语言图片替代。

`site/data/language-samples.json` 覆盖全部已登记语言，包含固定语句与字表样本，不从包名或包定义选择样文。
常用语句沿用项目现有样文，其余语句来自
[Pango 语言样文](https://docs.gtk.org/Pango/method.Language.get_sample_string.html)。
Pango 没有对应语句时，从
[Fontconfig 语言字表](https://fontconfig.pages.freedesktop.org/fontconfig/fontconfig-devel/)
选取分布于字表中的字符，图片替代文本标为“字表预览”。文字及来源写入该表，正常构建不联网、不动态翻译。
新增语言必须先补齐固定样文，否则构建报错。固定语句缺少可选字符时可使用同语言配置的字表备选，不跨语言回退。
未识别语言的字体统一使用“未知”中的符号、注音、常用字或罕见汉字样本；合集中的此类成员在“全部语言”下仍有图片。

`site/src/font-info.c` 通过 FreeType
读取每个集合成员和变体；`site/module/chinese-fonts-overlay-site/previews.scm` 根据实际字符映射挑选样文。
`site/src/render-samples.c` 使用 Pango、Fontconfig 与 Cairo 批量生成透明 PNG，按所选语言设置排版语言，
禁用字体回退并检查缺字；不会把系统替代字体渲染进样本。每个字重和可变字体命名款式单独渲染。
公开图片仍检查为非空白、横向且边框透明。网站不再依赖原有按包生成的图片分支；CI 图片生成工具和样文表保持原有行为。

浏览器按可见款式加载小型图片索引，再加载当前语言的 PNG，切换语言时立即隐藏旧图片，提供加载、失败和重试状态。 Hoot 负责筛选、URL
状态、预览选择、异步加载与重试；`web/bridge.js` 只提供浏览器 API 绑定和加载入口。`catalog.json` 导出 schema
4，款式的 `manifest` 指向静态语言图片索引； 完整 `previews.json` 包含每个款式的 `samples` 映射、样文内容、类型和
`defaultLanguage`。 索引与目录只包含公开路径，不包含本地字体路径。所有字体原文件留在本地构建环境中。

字体解析结果和语言样本缓存在忽略的 `site/.cache/`。字体、样文或渲染器变化会使相关缓存失效， 相同字体及样文跨包复用渲染结果，公开 PNG
再按内容哈希去重。完整网站先在同一文件系统的临时目录生成，全部成功后替换输出；构建失败保留上一次可用网站。

可在开发环境运行语言映射、字符覆盖、缺字回退、透明度和款式枚举检查：

```sh
$ nix develop .#site
$ cd site/build
$ make check
$ make distcheck
```

## 本地构建单个字体包

flake 的 `packages` 暴露聚合包，例如 `nix build .#lxgw-fonts`。验证单个字体包时，请通过 overlay
引用对应属性；下面的命令使用根目录 `flake.lock` 锁定的 nixpkgs：

```sh
nix build --impure --expr '
  let
    flake = builtins.getFlake (toString ./.);
  in
  (import flake.inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = [ flake.overlays.default ];
  }).lxgwPackages.neo-zhisong
'
```

将 `lxgwPackages.neo-zhisong` 替换为目标包的属性路径。命令中的 `allowUnfree`
允许验证非自由字体，不代表允许再分发。Git 工作区中的新文件需要先 `git add`，flake 才能读取它们。

使用 `import <nixpkgs>` 的构建命令依赖本机 Nix 搜索路径，可能与仓库锁定版本不同。构建后检查
`result/share/fonts/`，确认格式、文件数量和相关变体符合预期；需要时用 `fc-scan` 检查字体内部名称。

## 添加与更新字体包

添加字体前，按照
[create-font-package Skill](../.agents/skills/create-font-package/SKILL.md)
核对上游发布、下载内容、内部字体名称、版本、hash 和许可证，再确定包的组织方式。

1. 确认字体名称、发行商、官方来源和许可证，判断是否允许再分发。
2. 检查同一字体的相关变体。Mono、CL、MN、Plus、Screen
   等变体通常放在同一包内；具有不同用途或许可条件的独立字体应分别判断。变体版本不同的，分别固定来源和版本。
3. 编写 `package.nix`，接入 vendor scope，并在样本配置中为 `pname` 添加条目。
4. 格式化并构建单包，检查安装的字体和许可证文件。
5. 逐包提交并创建 PR，验证工作流生成的预览；也可以先在本地生成和检查。
6. 根据实际图片文件名补齐 README 条目和正式预览路径，作为最后的文档提交。

包定义需要准确填写 `pname`、`version`、来源和 `meta` 信息。单个来源使用 `src`，多个来源可使用
`srcs`；应覆盖包内全部变体，不要把某个变体的版本误用于其他来源。 `meta.longDescription` 保持简短、客观，并按 Skill 使用
ASCII 文本；许可证的具体附带文件要求也要落实到安装结果中。

更新已有字体时，同样检查上游发布和许可证变化，不要只替换 hash。检查下载文件名、格式、归档目录、安装逻辑和变体是否变化。构建失败的修复应在 PR
中保留旧日志、hash mismatch 或来源变化等依据。已有字体更新不会自动触发 PR 预览；需要刷新时按下节添加请求。

## 字体预览图维护

### PR 预览与 README

在 `tools/generate-font-preview-images/sample-keys.nix` 的对应 vendor 分组中，按包的
`pname` 选择样本。样本应覆盖字体支持的文字，符号字体应使用对应的符号样本。

PR 工作流为新增字体自动生成预览，将 PNG 发布到 `font-preview-prs`
分支，并更新一条预览评论。请逐张检查图片非空白、横向显示，且包内不同字重和变体都有对应图片。

README 使用 `font-preview-images` 分支的正式链接，路径应来自生成结果或 PR 评论中的预计正式路径。文件名由 `pname`
和字体内部名称等信息生成，不能根据上游下载文件名猜测。 URL 中的 `+`、空格等字符应正确编码，图片说明应与对应文件名一致。

正式图片由主线 CI 在合入后发布；新增图片的正式链接在 PR 阶段可能尚不存在。不可再分发字体可以有 PR 预览，但主线不会自动发布其正式图片；Windows
字体不参与这套自动构建和预览流程。遇到这些情况，请在 PR 中说明本地验证结果和需要维护者处理的事项。

### 刷新已有字体的预览

仅修改已有包的版本、字体文件或样本，不会自动要求 PR 重新生成预览。需要刷新时，在 `ci/default.nix` 的 `previewRequests`
中添加或更改请求标记，例如：

```nix
previewRequests = {
  "lxgw.neo-zhisong" = "refresh-screen-preview";
};
```

键使用 CI 的 `<vendor>.<包属性>`，这里是 `lxgw.neo-zhisong`，不是 `lxgwPackages.neo-zhisong` 或
`lxgw-neo-zhisong`。值使用与本次修复相关的非空字符串；再次刷新时更换标记，以便工作流识别新的请求。请同时说明刷新原因和检查结果。

### 本地生成与检查

维护本地预览时，遵循
[create-font-preview Skill](../.agents/skills/create-font-preview/SKILL.md)。如果仓库根目录还没有
`font-preview-images/`，先克隆正式图片分支：

```console
$ git clone --branch font-preview-images --single-branch https://github.com/brsvh/chinese-fonts-overlay.git font-preview-images
```

一次选择一个 `pname` 生成预览，例如：

```console
$ nix develop .#generator -c generate-font-preview-images --package-name lxgw-neo-zhisong
```

工具只构建所选字体，默认输出到 `font-preview-images/`。首次运行不加
`--override`：已有的有效图片会跳过，无效图片会报错。确认需要重绘或修复问题后，再针对该包使用 `--override`。

检查每张新 PNG 的宽度大于高度、颜色数量大于 1，并实际查看图片。仅看到命令成功不足以确认预览正确。预览目录是独立的 Git 仓库，PNG
不提交到主分支；常规 PR 使用自动发布流程，不需要手动推送图片分支。

## CI 与发布

### PR：GitHub Actions

[`check.yml`](../.github/workflows/check.yml) 运行格式检查和 `nix flake check`。
[`build.yml`](../.github/workflows/build.yml) 比较基线与 PR 的派生，选择需要构建或生成预览的字体，并复用同一
PR 中输入未变化的成功记录。仅改文档通常不会安排字体构建。

构建按是否允许缓存分组。每组不超过 128 个包时，一包一个任务，名称显示 `pname`；超出时才合并分片，含多个包的分片使用数字名称。Windows
字体被排除；其他不可再分发字体可以构建，但构建结果不保存到公开缓存。

[`preview-publish.yml`](../.github/workflows/preview-publish.yml)
由构建工作流触发，校验产物、发布临时预览并更新评论，最后报告 `Font previews`
检查结果。发布器固定使用默认分支上的可信代码。修改构建产物格式或任务名称时，要兼容主线发布器；仅在同一个 PR 内修改发布器，不会立即改变该 PR 的发布行为。

### 主线：Hercules CI

[`ci/hercules.nix`](../ci/hercules.nix) 为 `main` 安排
`plan`，再为符合条件的包分别调度缓存和预览任务。它只处理明确允许再分发且不属于 Windows 字体的包，并在发布前检查字体及其依赖。缓存发布到
`https://cache.bingshan.org`，正式 PNG 发布到 `font-preview-images` 分支。

`plan` 完成表示任务已安排，缓存和预览仍可能在各自任务中运行。PR
构建成功也不代表主线发布已经完成。排查时请区分计划、单包构建、缓存上传和预览发布，查看失败阶段的日志。遇到临时网络失败，可重试对应的失败任务；重试主线计划前应确认目标仍是当前主线版本。流程会核对已有发布记录，复用符合当前输入的结果。

## 许可证维护

优先使用 nixpkgs 已有的 `lib.licenses`；只有没有准确条目时，才在 `lib/licenses.nix`
中添加自定义许可证。明确允许再分发字体文件时，才设置
`meta.redistributable = true`。允许免费下载、个人使用或商业使用，都不能单独证明允许再分发；条款不清楚时设置为 `false`，并在
PR 中说明依据。

按上游要求安装许可证、版权说明及其他必要文本。例如 IPA 字体需要保留许可证和原始字体替换说明。不可再分发字体及其来源文件不能通过
CI、公开缓存或提交到仓库的方式传播。

## 格式化、验证与提交

提交前运行：

```console
$ nix fmt
$ nix fmt --no-update-lock-file --no-write-lock-file -- --fail-on-change
$ nix flake check --no-update-lock-file --no-write-lock-file --print-build-logs
```

`nix fmt` 使用仓库配置，可在开发 shell 外运行。格式化后检查差异，尤其是 Markdown 换行和中英文空格。
`nix flake check` 检查 flake 求值及声明的 checks，不会构建全部字体；修改包定义后仍需单独构建受影响的包。

提交前检查 `git status --short`、`git diff --cached --stat` 和
`git diff --cached`，确认暂存内容。进入开发环境后执行提交，让提交前检查使用完整的工具环境。每个包独立提交，提交信息遵循[贡献指南](CONTRIBUTING.md#%E6%8F%90%E4%BA%A4%E7%BB%84%E7%BB%87%E4%B8%8E%E6%8F%90%E4%BA%A4%E4%BF%A1%E6%81%AF)和
commit Skill。在 PR 中列出实际验证命令、结果和未覆盖的情况。

## AI Agent 使用说明

Agent 应先读取根目录 [AGENTS.md](../AGENTS.md)；网站任务还需读取
[site/AGENTS.md](../site/AGENTS.md)，其中维护网站结构、数据和发布约定。根目录提供 C、Guile 和 Hoot
技能的使用指引，再按任务使用以下项目 Skills：

- [create-font-package](../.agents/skills/create-font-package/SKILL.md)：分析来源、字体变体、许可证和包结构。
- [create-font-preview](../.agents/skills/create-font-preview/SKILL.md)：生成或修复指定
  `pname` 的预览图。
- [nix-coding](../.agents/skills/nix-coding/SKILL.md)：写入、修改或审阅 `.nix`
  文件前读取，并遵循引用的风格指南。
- [commit](../.agents/skills/commit/SKILL.md)：检查暂存差异，编写 GNU 风格提交信息并提交。

贡献者与维护者需要核对来源、构建结果和预览图，对许可证和再分发结论负责；许可证不清楚时，应记录原文依据和不确定之处。

## 常见问题排查

- `hash mismatch`：先确认下载内容是否为预期字体、上游是否替换了资产，再更新 hash。
- 下载失败：检查重定向、请求头要求和发布资产名称；更换来源时说明可信依据。
- 构建成功但字体缺失：检查 `installPhase`、扩展名和目录。OpenType 通常安装到
  `$out/share/fonts/opentype/<vendor>/`，TrueType 通常安装到
  `$out/share/fonts/truetype/<vendor>/`。
- 包名不一致：区分目录名、overlay 属性和 `pname`。例如目录 `packages/lxgw/neo-zhisong/` 对应
  `lxgwPackages.neo-zhisong`，预览命令与样本配置使用 `lxgw-neo-zhisong`，CI 请求使用
  `lxgw.neo-zhisong`。
