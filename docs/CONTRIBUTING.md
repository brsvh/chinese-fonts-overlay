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

当然，如果您实在无法使用模板，我们同样接受您的自定义内容的 PR，但会在讨论过程中会要求您提供相应模板中所需的必要信息。

## 添加新字体

添加新字体时，请确认这些事项：

- 字体名称、字体发行商和来源 URL 是准确的。
- 字体来源 URL 可以公开访问，或至少能让维护者确认来源。
- 已检查字体许可证和再分发限制。
- 没有把不可再分发的字体源文件上传到仓库或缓存服务。
- `package.nix` 中的 `meta.license`、`meta.homepage` 和 `meta.redistributable`
  符合实际情况。
- 字体包已经接入对应的 vendor scope。
- README 中的字体列表或说明已经更新。

如果新增字体需要预览图，请在 PR 中请求 `@brsvh` 生成或更新字体预览图片。

## 修复构建失败

修复已有字体包时，请说明：

- 受影响的字体包名，例如 `fooPackages.bar`。
- 修复前的失败现象，最好包含相关的 `nix log` 输出。
- 修改了哪些来源 URL、hash、安装逻辑或元数据。
- 修复后执行过哪些验证命令。

如果更换了来源 URL 或 hash，请说明新来源为什么可信。

## 验证构建

请验证您实际改动的字体包，并在 PR 中列出执行过的命令和结果。

可以用下面的形式从仓库根目录注入 overlay 并构建单个字体包：

```console
$ NIXPKGS_ALLOW_UNFREE=1 nix build --impure --expr 'with import <nixpkgs> { overlays = [ (import ./default.nix) ]; }; tsangertypePackages.tsangerjinkai'
```

请把 `tsangertypePackages.tsangerjinkai` 替换为实际字体包名。

如果字体是自由许可证且不需要 unfree 支持，也可以省略 `NIXPKGS_ALLOW_UNFREE=1`。不确定时保留它即可。

## 许可证注意事项

这个仓库包含一些不可再分发的字体包。贡献时请特别注意：

- 不要把字体文件直接提交到仓库，除非许可证明确允许且维护者同意。
- 不要将不可再分发字体利用 CI 等上传到公开缓存服务或 substituter server。
- 不要只根据“免费下载”判断许可证；免费下载不等于允许再分发。
- 如果许可证条款不清楚，请在 issue 或 PR 中说明不确定之处。

## 其他改动

文档、工具、仓库配置或元数据改动请使用其他改动 PR 模板。请说明改动范围、影响的命令或文件，以及您执行过的验证。
