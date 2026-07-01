## 修复对象

请说明这个 PR 修复的构建问题。

- [ ] 修复/更新 `受影响的字体包名`

<!-- 相关 issue，没有请移除 -->

fix #NUM

## 失败现象

请粘贴或概述修复前的失败现象。

```text
# 例如：
# nix log /nix/store/...-package.drv
```

## 修复内容

请简要说明这个 PR 如何修复构建问题。

- [ ] 已修复构建失败。
- [ ] 如改动了来源 URL 或 hash，已确认新来源可信。
- [ ] 如改动影响用户使用方式，已更新 README 或相关代码、文档。

## 验证

请列出已经执行的验证命令和结果。

```text
# 例如：
# NIXPKGS_ALLOW_UNFREE=1 nix build --impure --expr 'with import <nixpkgs> { overlays = [ (import ./default.nix) ]; }; fooPackages.bar'
```

## 其他说明

请补充评审者需要知道的其他信息。
