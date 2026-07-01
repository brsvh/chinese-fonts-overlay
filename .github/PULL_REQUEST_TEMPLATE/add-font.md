## 新字体信息

请说明这个 PR 添加的字体。

- [ ] `字体包名` - 字体名称，字体发行商，URL

<!-- 相关 issue，没有请移除 -->

fix #NUM

## 许可证与再分发

请说明字体许可证和再分发限制。

- [ ] 已检查字体许可证。
- [ ] 已确认是否允许再分发字体文件。
- [ ] 已在 `package.nix` 中正确填写 `meta.license`。
- [ ] 如字体不可再分发，已确认不会上传字体文件到仓库或缓存服务。

## 实现内容

- [ ] 已添加字体包。
- [ ] 已将字体包接入对应的 vendor scope。
- [ ] 已更新 README 中的字体列表或说明。
- [ ] 请求 @brsvh 生成或更新字体预览图片。

## 验证

请列出已经执行的验证命令和结果。

```text
# 例如：
# NIXPKGS_ALLOW_UNFREE=1 nix build --impure --expr 'with import <nixpkgs> { overlays = [ (import ./default.nix) ]; }; fooPackages.bar'
```

## 其他说明

请补充评审者需要知道的其他信息。
