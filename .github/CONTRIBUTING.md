# 贡献指南

欢迎补充字体、修复打包问题，或改进预览网站。提交前请核对字体来源和许可，并实际检查改动后的结果。

## 提问题

按情况选择模板：

- [请求添加字体](https://github.com/brsvh/chinese-fonts-overlay/issues/new?template=font-request.yml)：提供名称、发行商、上游地址和已知许可。
- [报告构建失败](https://github.com/brsvh/chinese-fonts-overlay/issues/new?template=font-build-failure.yml)：提供包名、构建命令和相关日志。
- [其他问题](https://github.com/brsvh/chinese-fonts-overlay/issues/new?template=other.yml)：说明现象和期望结果。网站问题请补充浏览器、筛选条件或截图。

## 修改字体包

包定义位于 `packages/<字库>/<字体>/package.nix`。先参考同一字库的现有包，确认版本、来源、hash、安装文件和许可证。
同一字体的字重、集合成员和相关变体应完整保留；是否拆包按上游产品和许可判断。

已有字库会自动发现新包。新增字库还需接入 `overlays/default.nix`、`flake.nix`，并在 `lib/font-info.nix`
中登记字库标识。字体名称、许可和分类以包定义为准，预览网站从中生成目录，不维护另一份 README 字体列表。

请填写 `passthru.chinese-fonts-overlay-site` 的
`displayName`、字库、风格、费用分类和语言覆盖；需要说明的限制放在该包的 `notices` 中。 `displayName`
使用发行方主页或发行说明中的家族或产品名称，优先采用其本地语言名称。 不要拼接同一家族的字重名称或重复译名；分别打包的地区版、独立家族和可变版本应保留区别。
语言覆盖由扫描结果填写，其他分类人工核对。操作和字段说明见 [网站文档](../site/README)。

费用分类遵循 `gpu` / `gcu` / `paid` 的许可获取约定，网站分别使用 `gratisPersonalUse` /
`gratisCommercialUse` / `paid`，无许可费使用 `free`。
分类不表示所有场景的费用一致：屏显可免费获取个人使用许可、打印另行收费的字体仍可归为 `gratisPersonalUse`。需要说明的适用范围和限制写入
`notices`，详见网站文档。

安装结果应包含上游要求的许可证和版权说明。`meta.redistributable` 只在明确允许再分发字体文件时设为 `true`；无法确认时设为
`false` 并记录依据。允许免费下载或商用不等于允许再分发。受限字体及其来源文件不得上传到公开缓存或随 PR 提交。

## 本地验证

从仓库根目录进入开发环境：

```sh
nix develop
```

环境提供格式化工具和提交前检查。配置维护在 `tools/dev-shells/default.nix`；生成的配置链接不提交。
字体包使用根目录的锁定依赖，开发工具使用 `tools/flake.lock`，更新时请区分。

使用仓库锁定的 nixpkgs 构建单个字体：

```sh
nix build --impure --expr '
  let
    flake = builtins.getFlake (toString ./.);
  in
  (import flake.inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = [ flake.overlays.default ];
  }).justfontPackages.huninn
'
```

将 `justfontPackages.huninn` 换成目标包。新文件需先 `git add`，flake 才能读取。 检查
`result/share/fonts/` 中的格式、数量和变体；来源或 hash 变化时，确认下载内容没有被上游替换为错误文件。

按改动范围验证：

- 包定义：构建受影响的包，检查安装内容和预览；字体变化后重新扫描语言覆盖。
- 网站：按 [site/README](../site/README) 构建并运行功能测试，界面变化还需在浏览器中检查。
- Nix 或开发工具：运行格式检查及相关求值检查。
- 纯文档：检查示例、链接和排版，无需构建整个字体集合。

常用检查命令：

```sh
nix fmt
nix fmt --no-update-lock-file --no-write-lock-file -- --fail-on-change
nix flake check --no-update-lock-file --no-write-lock-file --print-build-logs
```

`nix flake check` 不替代单包构建。C 的 clang-format 和 Makefile 的 mbake 为按需工具， 具体约定见
[维护指引](../AGENTS.md)。在 PR 中写明实际执行的检查和未完成的部分。

## 预览与现有 CI

网站目前尚未部署，预定地址为 <https://brsvh.github.io/chinese-fonts-overlay/>。
字体效果在本地网站中检查；网站样文按语言维护，详见 [网站数据维护说明](../site/README)。

现有 CI 仍独立生成按包的预览图。新增包时，继续在
[`sample-keys.nix`](../tools/generate-font-preview-images/sample-keys.nix) 中按
`pname` 选择样本，Windows 字体除外。不要把这张表当作网站的样文配置，也不需要将生成的图片链接复制到 README。

已有包更新不会自动请求重绘 PR 预览。确需刷新时，在 `ci/default.nix` 的 `previewRequests`
中添加或更换标记，并说明原因，例如：

```nix
previewRequests = {
  "lxgw.neo-zhisong" = "refresh-screen-preview";
};
```

键使用 `<字库>.<包属性>`，值使用本次刷新对应的非空标记。需要本地检查旧预览工具时，可指定输出目录：

```sh
nix develop .#generator -c generate-font-preview-images \
  --package-name lxgw-neo-zhisong --output-dir /tmp/font-previews
```

已有有效图片默认复用；确认要重绘时再加 `--override`。实际查看图片，确认有内容、横向排列且覆盖应有的款式。

当前 PR 检查包括 `Flake checks`、`Package builds` 和 `Font previews`。
构建和预览会复用输入未变的成功结果，Windows 字体不参与自动构建。 PR 预览评论来自现有图片发布流程；修改发布器时，要兼容仍运行于默认分支的版本。

主线 Hercules CI 仅向公开缓存发布明确允许再分发、且不属于 Windows 字体的包， 并将正式预览发布到
`font-preview-images` 分支。PR 检查通过不代表主线发布已完成。 网站部署将另行接入，当前仍使用上述流程。

## 提交修改

按目的拆分提交。独立字体的新增或版本更新逐包提交；统一的元数据整理可以合为一笔。 同一目的需要的代码、测试和说明应一起审查。

提交信息使用 `scope: Verb summary`，正文以 `* path: Change.` 按路径列出改动。 新增、更新字体版本分别使用
`<pname>: Init at <版本>` 和 `<pname>: Update to <版本>`。 细则见
[提交技能](../.agents/skills/commit/SKILL.md)，提交信息沿用英文格式。

创建 PR 时选择 [添加字体](PULL_REQUEST_TEMPLATE/add-font.md)、
[修复构建](PULL_REQUEST_TEMPLATE/fix-build.md) 或
[其他改动](PULL_REQUEST_TEMPLATE/other.md) 模板。 GitHub 没有自动载入时，在创建 PR 的地址后加上
`?template=add-font.md` 等参数。 说明改动原因、使用影响和验证结果即可，不必复述每个实现步骤。

项目说明使用中文；根目录和各目录的默认说明使用带 Org 模式声明的 `README`。 社区文件保留 GitHub 支持的格式，技能文档统一使用英文。AI
辅助的改动也需要贡献者核对来源、代码和验证结果。
