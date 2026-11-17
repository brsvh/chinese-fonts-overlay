# Skills 使用说明

这些 skills 可以复制到其他机器或安装到其他项目。安装时复制整个 skill 目录，保留其中的
`SKILL.md`、`references/`、`scripts/` 和 `examples/`，不要只复制 `SKILL.md`。各 skill
的相对资源链接均以自身安装目录为基准。

## 使用范围

- `c-coding`：GNU 风格 C、资源所有权和本地库边界。
- `guile-coding`：原生 Guile 模块、脚本与测试。
- `guile-web-coding`：原生 Guile HTTP 服务和 SXML/HTML 生成。
- `hoot-coding`：编译为浏览器 Wasm 的 Scheme 及其宿主交互。
- `nix-coding`：Nix 编码风格、格式化与验证。
- `commit`：在明确要求提交时审查暂存区并编写 GNU 风格提交信息。
- `create-font-package`：兼容 Chinese-fonts-overlay 布局的 Nix 字体打包流程。
- `create-font-preview`：兼容该布局的字体预览分支生成与修复流程。

## 在其他环境使用

先确定目标工作区，读取适用的 `AGENTS.md` 和开发说明，再查找实际构建入口、 工具版本和格式化配置。目标仓库路径与 skill
安装路径是两个独立的位置；不要假设 当前目录、用户主目录、Nix store 路径或缓存与技能作者的机器相同。项目的架构、
界面语言、网站数据和发布规则由目标项目维护，不由通用语言 skill 决定。

配套 skill 按当前环境提供的名称查找，不要求相邻安装。若项目明确要求某个缺失的 skill，应说明缺失；可选配套 skill
不可用时，使用目标项目的规则和已安装的参考资料。 字体工作流保留专用布局约定，但执行前必须核对实际路径、预览分支、Git 远端和
发布地址，不能把原始仓库地址直接套用到其他人的 fork。

## 附带验证脚本

脚本是参考示例的可选验证工具，不是目标应用的依赖或强制 CI 检查。它们从自身 位置读取附带资源，不要求从特定目录启动，不下载依赖。按对应参考文档准备工具，
在新建且属于当前任务的临时目录中生成结果。

- Python 脚本要求 Python 3.10 或更新版本，文本资源使用 UTF-8。
- C 示例验证脚本目前针对原生 Linux/ELF，需要带 ASan/UBSan 的 C 编译器、 支持 Rust 2024 edition 的
  Rust、Guile 3 开发库和 pkg-config。
- HTTP 示例验证脚本使用 POSIX 信号和管道，需要 Guile 3 与原生 Fibers，自动 分配本地端口并清理自身启动的服务。
- Hoot 示例构建需要所选版本的 Hoot；宿主适配器测试还需 Node.js，实际浏览器验证 需要该 Hoot 运行时支持的 Wasm 功能。

可通过相应脚本支持的 `CC`、`RUSTC`、`PKG_CONFIG`、`GUILE` 或 `HOOT` 选择工具。 这些值按 shell
参数语法拆分，但不经过 shell 执行；含空格的可执行文件路径需要 在变量值中加引号。依赖缺失和平台不支持必须明确报告，不能算作验证通过。
