# 维护指引

## 适用范围

本文件适用于整个仓库；涉及某个目录时，还需读取其中更具体的 `AGENTS.md`。 网站相关工作必须读取
[site/AGENTS.md](site/AGENTS.md)，包括位于 `site/` 外的 Nix 注册和开发工具配置。
网站的架构、数据和发布约定放在那里，语言技能只维护实现惯例。

## 文档

项目默认说明是根目录的 [README](README)。项目文档使用中文；技能及其使用说明使用英文，保留 Markdown 格式。
项目和代码目录的默认说明使用 `README`，第一行为 `# -*- mode: org; -*-`，采用 Org 标题、链接和源码块。 社区文件放在
`.github/`，保留 GitHub 支持的 Markdown 或 YAML 格式。

Org 文档每行最多 80 个显示列，按完整源码行计算，包含标记和链接地址。 中文和全角标点按两列，ASCII 字符按一列；正文中英文之间保留一个空格。
换行时不拆开单词、代码或链接地址，长链接可以换行描述文字。 核验时使用 Emacs 的 `string-width` 等显示宽度计算，不能用字符数代替。

字体列表、预览和许可信息由网站展示，不向 README 追加逐包图片。 贡献流程维护在
[.github/CONTRIBUTING.md](.github/CONTRIBUTING.md)，网站操作维护在
[site/README](site/README)，不再建立 `docs/` 或独立的开发文档副本。
预览网站地址目前只是预设，不能描述为已经部署；未经明确请求，不修改部署流程。

## Nix

写入、修改、审查或重构 `.nix` 文件前，先使用
[nix-coding](.agents/skills/nix-coding/SKILL.md)，读取其引用的风格指南，并按要求格式化和验证。

## C 与 Scheme

按代码的执行目标选择技能：

| 工作                                   | 技能                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------- |
| 手写 C 和原生字体工具                  | [c-coding](.agents/skills/c-coding/SKILL.md)                                          |
| 原生 Guile 模块、脚本和测试            | [guile-coding](.agents/skills/guile-coding/SKILL.md)                                  |
| 原生 HTTP 处理和 SXML/HTML             | [guile-web-coding](.agents/skills/guile-web-coding/SKILL.md)，同时遵循原生 Guile 指引 |
| 编译到浏览器 Wasm 的 Scheme 及宿主接口 | [hoot-coding](.agents/skills/hoot-coding/SKILL.md)                                    |

跨原生 Guile 和 Hoot 运行的模块需要同时遵循两套指引。编译端可用的 Guile 依赖不一定可在 Wasm 中使用。

## 开发配置

配置维护在 `tools/dev-shells/default.nix`。`nix develop` 生成 `.bake.toml`、
`.clang-format`、`.editorconfig`、`prek.toml` 和 `treefmt.toml` 的忽略链接。 修改对应的 Nix
定义，不编辑或提交生成文件。

C 使用 GNU 风格。开发环境提供 GNU 预设的 clang-format，按需使用并检查差异。 没有明确请求时，不把它加入 treefmt、提交检查或
CI，也不格式化无关源码。

手写的 `Makefile`、`GNUmakefile`、`makefile`、`*.mk` 和 `Makefile.am` 最多 80 列，
命令前缀使用真正的 Tab。开发环境提供 bake 项目的 mbake；从仓库根目录运行
`mbake format --config .bake.toml FILE`，只检查时加 `--check`。

锁定版本的 mbake 不会拆分或拒绝超长行，行宽使用 `editorconfig-checker -disable-indentation FILE`
检查。缩进交给 mbake，避免把合法的空格续行误判为缺少 Tab。 手动换行时保留 Make 和 shell 的引号、空白语义。生成的
`Makefile.in` 和配置后的 Makefile 不参与格式化。

## 提交

创建提交时使用 [commit](.agents/skills/commit/SKILL.md)，完成规定的暂存区检查， 并采用 GNU
风格提交信息。拆分原则见 [贡献指南](.github/CONTRIBUTING.md)。
