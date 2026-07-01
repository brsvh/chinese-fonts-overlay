# 开发文档

## 目标与适用范围

本文档面向准备直接修改仓库的维护者和贡献者。

[CONTRIBUTING.md](CONTRIBUTING.md) 说明如何提出 issue 和 PR。

本文档说明本地开发时如何改包、验证构建、处理许可证和维护预览图。

## 仓库结构

- `packages/<vendor>/<font>/package.nix`：字体包定义。
- `overlays/default.nix`：组织 vendor scope，并暴露聚合包。
- `lib/licenses.nix`：本仓库自定义许可证。
- `tools/generate-font-preview-images`：README 预览图生成工具。

已有 vendor scope 通常会自动发现新包。

向已有 vendor 添加字体时，一般只需要新增对应的 `package.nix`。

新增 vendor 时，再修改 overlay、flake 暴露和 README 分组。

## 本地构建单个字体包

本仓库的 flake 只暴露部分聚合包。

请从仓库根目录注入 overlay：

```console
$ NIXPKGS_ALLOW_UNFREE=1 nix build --impure --expr 'with import <nixpkgs> { overlays = [ (import ./default.nix) ]; }; tsangertypePackages.tsangerjinkai'
```

将 `tsangertypePackages.tsangerjinkai` 替换为实际 attr path。

例如自由字体可以使用 `justfontPackages.huninn`。

许多字体是 unfree 或不可再分发。

验证时默认保留 `NIXPKGS_ALLOW_UNFREE=1`。

确认目标字体是自由许可证时，可以省略它。

## 添加新字体包

添加字体包时，先确认来源和许可证，再写 Nix 表达式。

不要先写包，最后才回头补许可证判断。

基本流程：

1. 确认字体名称、发行商、主页和下载 URL。
2. 确认许可证是否允许再分发字体文件。
3. 选择 vendor scope 和包目录。
4. 编写 `packages/<vendor>/<font>/package.nix`。
5. 本地构建单个字体包。
6. 检查输出目录中的字体文件。
7. 更新 README 中的字体列表或说明。
8. 需要时生成或请求生成预览图。

`package.nix` 至少应认真填写这些字段：

- `pname`
- `version`
- `src`
- `meta.homepage`
- `meta.license`
- `meta.redistributable`

如果包安装多个字体文件，请检查文件名、格式和安装目录。

## 更新已有字体包

更新已有字体包时，不要只改 hash。

请同时检查上游发布信息和许可证是否有变化。

常见检查项：

- `version` 是否对应上游实际版本。
- `url` 是否仍然指向官方或可信来源。
- `hash` 是否只因为上游文件更新而变化。
- 字体文件名、格式、目录结构是否变化。
- `installPhase` 是否仍安装了所有需要的字体文件。
- README 中的链接、说明或预览图是否需要更新。

修复构建失败时，请保留能解释问题的上下文。

例如旧的 `nix log`、hash mismatch 信息或上游 URL 变化说明。

## 许可证维护

优先使用 nixpkgs 已有的 `lib.licenses`。

只有当 nixpkgs 没有准确条目时，才新增自定义许可证。

自定义许可证放在 `lib/licenses.nix`。

判断 `meta.redistributable` 时按保守原则处理：

- 明确允许再分发字体文件，才设置为 `true`。
- 只允许下载、安装、个人使用或商业使用，不等于允许再分发。
- 条款不清楚时，设置为 `false`。
- 不确定依据时，在 PR 或注释中说明。

不要提交不可再分发的字体文件。

不要通过 CI、公开 cache 或 substituter server 分发这类字体。

## 字体预览图维护

预览图保存在 `font-preview-images` 分支。

主分支不直接存放预览 PNG。

维护预览图时关注三件事：

- 为包选择合适的 sample key。
- 生成后的 PNG 不能是空白图。
- 预览图方向应保持横向。
- README 预览链接必须对应实际生成的文件名。

常见 sample key 包括简体中文、繁体中文、英文和符号。

普通贡献者不一定需要自己生成预览图。

新增字体需要预览时，可以在 PR 中请求 __@brsvh__ 处理。

维护者可使用 `create-font-preview` skill 或相关工具生成和校验。

## 格式化与验证

提交前至少运行格式化：

```console
$ treefmt
```

修改 `.nix` 文件后，还应构建受影响的字体包。

修改 Markdown 后，请检查 mdformat 可能引入的异常换行。

也要检查中英文之间是否出现错误空格。

如果某个改动需要更宽的验证，请在 PR 中说明运行了什么命令。

## AI Agent 使用说明

可以使用 AI agent 辅助维护。

贡献者与维护者仍然负责最终判断，尤其是许可证和再分发结论。

本仓库提供这些 skill：

- `create-font-package`：分析上游 URL、字体文件、许可证和包形状。
- `create-font-preview`：为指定 package `pname` 生成或修复预览图。
- `nix-coding`：修改 `.nix` 文件前使用，确保符合本仓库风格。
- `commit`：根据 staged diff 编写 GNU 风格提交信息并执行提交。

适合交给 agent 的工作：

- 初步查找上游信息。
- 草拟 `package.nix`。
- 整理 README 条目。
- 运行构建命令。
- 检查预览图。

不适合完全交给 agent 的工作：

- 判断模糊许可证。
- 决定是否可以再分发字体文件。
- 替代判断上游来源是否可信。

## 常见问题排查

`hash mismatch` 通常表示上游文件更新、下载到了错误页面，或 URL 会变化。

先确认下载内容，再更新 hash。

下载失败时，检查上游是否需要跳转、referer 或 user-agent。

也要检查发布资产是否已经改名。

不要改到非官方镜像，除非能说明来源可信。

构建成功但没有字体文件时，检查 `installPhase`。

同时检查字体扩展名和输出目录。

OpenType 字体通常放在 `$out/share/fonts/opentype/<vendor>/`。

TrueType 字体通常放在 `$out/share/fonts/truetype/<vendor>/`。

包名或 attr path 不一致时，检查这些位置：

- `pname`
- 目录名
- README 条目
- `overlays/default.nix` 中的 vendor scope

`pname` 用于 derivation 名称。

attr path 用于用户在 overlay 中引用包。

两者不总是完全相同。
