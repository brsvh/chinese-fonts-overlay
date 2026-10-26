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
- `.github/workflows/`：PR 的格式检查、字体构建和预览发布工作流。
- `.agents/skills/`：打包、预览、Nix 风格和提交规范。

已有 vendor scope 会从包目录发现新包。新增 vendor 时，还需要接入 overlay、flake 聚合包、预览样本分组和 README；例如
LXGW 使用 `packages/lxgw/`、`lxgwPackages` 和 `lxgw-fonts`。

## 开发环境

从仓库根目录进入默认开发环境：

```console
$ nix develop
```

该环境提供 Git、treefmt、nixfmt、mdformat、Biome 和 prek，并安装提交前格式检查。需要字体预览工具时，使用
`nix develop .#generator`。

进入环境会生成 `.editorconfig`、`prek.toml` 和 `treefmt.toml` 的符号链接。这些文件不提交到仓库；修改配置时应编辑
`tools/dev-shells/default.nix`。开发工具与字体包使用不同的锁定输入，更新依赖时请确认修改的是根目录还是 `tools/`
下的锁文件。

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

Agent 应先读取根目录 [AGENTS.md](../AGENTS.md)，再按任务使用项目 Skills：

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
