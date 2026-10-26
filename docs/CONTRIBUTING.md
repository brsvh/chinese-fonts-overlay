# 贡献指南

感谢您愿意帮助改进 Chinese Fonts Overlay。这个项目主要维护中文字体在 Nix/NixOS
中的打包方式；贡献时请优先保证来源、许可证和构建结果清楚可验证、可复现。

## 创建 issue

如果您还没有准备好提交 PR，请先开对应的 issue：

- [请求添加新字体](https://github.com/brsvh/chinese-fonts-overlay/issues/new?template=font-request.yml)
- [报告字体构建失败](https://github.com/brsvh/chinese-fonts-overlay/issues/new?template=font-build-failure.yml)
- [反馈其他问题](https://github.com/brsvh/chinese-fonts-overlay/issues/new?template=other.yml)

请求添加新字体时，请至少提供字体名称、字体发行商和能够找到该字体的 URL。如果您了解许可证状况，也请一并说明。

报告构建失败时，请提供字体包名和相关的 `nix log` 输出。

## 提交 PR

本仓库提供三类 PR 模板。GitHub 不会像 issue forms 一样显示模板选择器；如果模板没有自动出现，请在创建 PR 的 URL 中加入对应的
`template` 参数：

- 添加新字体：`?template=add-font.md`
- 修复构建失败：`?template=fix-build.md`
- 文档、工具、仓库配置或其他改动：`?template=other.md`

也可以使用这些链接作为起点：

- 添加新字体
  PR：<https://github.com/brsvh/chinese-fonts-overlay/compare/main...YOUR_BRANCH?quick_pull=1&template=add-font.md>
- 修复构建失败
  PR：<https://github.com/brsvh/chinese-fonts-overlay/compare/main...YOUR_BRANCH?quick_pull=1&template=fix-build.md>
- 其他改动
  PR：<https://github.com/brsvh/chinese-fonts-overlay/compare/main...YOUR_BRANCH?quick_pull=1&template=other.md>

请将链接中的 `YOUR_BRANCH` 替换为您的分支名。

请使用与改动对应的模板，并填写适用的字段。通过命令行创建 PR 时，也请按照
[模板内容](../.github/PULL_REQUEST_TEMPLATE)填写正文；如果无法直接使用模板，请提供其中要求的信息。

### 提交组织与提交信息

涉及多个字体包时，每个包单独提交，同一字体的相关变体在同一包内维护。工具、CI 和文档改动单独提交，便于逐项评审。新增字体的 README
预览条目放在图片验证之后，作为最后的文档提交。

提交信息使用 GNU 风格：标题为 `scope: Verb summary`，正文按文件路径排序，以 `* path: Change.`
列出改动。新增或更新字体包时，标题使用包的 `pname`，分别写作 `<pname>: Init at <version>` 和
`<pname>: Update to <version>`。具体要求见
[commit Skill](../.agents/skills/commit/SKILL.md)。

## 添加新字体

添加新字体时，请确认这些事项：

- 字体名称、字体发行商和来源 URL 是准确的。
- 字体来源 URL 可以公开访问，或至少能让维护者确认来源。
- 已检查字体许可证和再分发限制。
- 没有把不可再分发的字体源文件上传到仓库或缓存服务。
- `package.nix` 中的 `meta.license`、`meta.homepage` 和 `meta.redistributable`
  符合实际情况。
- 字体包已经接入对应的 vendor scope。
- 已检查同一字体的 Mono、Screen 等变体，避免遗漏或把相关变体拆成多个包。
- 已按包的 `pname` 配置预览样本，并验证实际生成的图片。
- README 中的字库清单、字体条目和预览链接已经更新。

新增字体的预览由 PR 工作流自动生成。请先提交包定义和
[`sample-keys.nix`](../tools/generate-font-preview-images/sample-keys.nix)
中的样本配置，再检查 PR 里的预览评论，确认图片非空白、方向正确且覆盖包内变体，最后更新 `docs/README.md`。

README 使用评论中列出的预计正式路径，不使用 `font-preview-prs`
分支的临时图片链接。允许发布的正式图片在合入主线后生成，因此合入前正式链接可能尚不可访问。 Windows 字体不参与自动构建和预览；不可再分发字体的 PR
预览也不会自动成为主线正式图片。这些情况请在 PR 中说明验证方式和预览安排。

已有字体需要重新生成预览时，请按[开发文档](development.md#%E5%AD%97%E4%BD%93%E9%A2%84%E8%A7%88%E5%9B%BE%E7%BB%B4%E6%8A%A4)添加明确的刷新请求。

## 修复构建失败

修复已有字体包时，请说明：

- 受影响的字体包名，例如 `fooPackages.bar`。
- 修复前的失败现象，最好包含相关的 `nix log` 输出。
- 修改了哪些来源 URL、hash、安装逻辑或元数据。
- 修复后执行过哪些验证命令。

如果更换了来源 URL 或 hash，请说明新来源为什么可信。

## 验证构建

从仓库根目录进入开发环境并运行检查：

```console
$ nix develop
$ nix fmt
$ nix flake check --no-update-lock-file --no-write-lock-file --print-build-logs
```

开发环境会安装格式化工具和提交前检查。请检查格式化后的差异，并构建实际修改的字体包； `nix flake check`
不会替代逐包构建。文档改动无需构建整个字体集合。

单包构建建议使用[开发文档中的锁定输入命令](development.md#%E6%9C%AC%E5%9C%B0%E6%9E%84%E5%BB%BA%E5%8D%95%E4%B8%AA%E5%AD%97%E4%BD%93%E5%8C%85)。如果需要验证本机
`<nixpkgs>` 下的兼容性，也可以注入 overlay：

```console
$ NIXPKGS_ALLOW_UNFREE=1 nix build --impure --expr 'with import <nixpkgs> { overlays = [ (import ./default.nix) ]; }; tsangertypePackages.tsangerjinkai'
```

请把 `tsangertypePackages.tsangerjinkai` 替换为实际字体包名。

如果字体是自由许可证且不需要 unfree 支持，也可以省略 `NIXPKGS_ALLOW_UNFREE=1`。请在 PR
中列出实际执行的命令和结果，包括未能完成的验证。

### PR 检查

- `Flake checks`：检查格式并执行 `nix flake check`。
- `Package builds`：汇总受影响字体包的构建结果；没有需要重新构建的包时，构建任务可以跳过。
- `Font previews`：校验预览产物并更新 PR 预览评论；需要预览时，请实际查看评论中的图片。

工作流会复用同一 PR 中已验证且输入未变化的结果。只更新 README 通常不会重新构建字体。 PR
检查通过与主线发布完成是两个阶段，详见[开发文档的 CI 说明](development.md#ci-%E4%B8%8E%E5%8F%91%E5%B8%83)。

## 许可证注意事项

这个仓库包含一些不可再分发的字体包。贡献时请特别注意：

- 不要把字体文件直接提交到仓库，除非许可证明确允许且维护者同意。
- 不要将不可再分发字体利用 CI 等上传到公开缓存服务或 substituter server。
- 不要只根据“免费下载”判断许可证；免费下载不等于允许再分发。
- 如果许可证条款不清楚，请在 issue 或 PR 中说明不确定之处。

## 其他改动

文档、工具、仓库配置或元数据改动请使用其他改动 PR 模板。请说明改动范围、影响的命令或文件，以及您执行过的验证。
