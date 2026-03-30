# AI Coding Playbook（v1）

## 1. 任务入口

- 路由与壳层：优先查看 `packages/app_shell`
- 通用契约与工具：优先查看 `packages/foundation`
- 网络策略：优先查看 `packages/networking`
- UI 规范：优先查看 `packages/design_system`
- 业务模块：在 `packages/feature_*` 内按模块改动

## 2. 禁止改动区（无明确需求时）

- 不跨包引用他包 `src/` 内部实现
- 不在基座包内引入业务包依赖
- 不修改公开 contract 名称与语义（除非需求明确要求）
- 不绕过质量门禁（analyze/test/verify）

## 3. 标准改动流程

1. 先定位改动范围（app*shell/foundation/networking/feature*\*）
2. 仅改必要文件，保持公共接口稳定
3. 增补对应测试（优先 contract 和关键分支）
4. 执行 `melos run verify:all`
5. 在 PR 描述中补充风险与回滚点

## 4. PR 模板建议

- 变更目标：
- 影响范围：
- 风险等级（P0/P1/P2）：
- 回滚方案：
- 测试结果（命令 + 结论）：

## 5. 快速命令

```bash
melos run analyze
melos run test
melos run verify:deps
melos run verify:all
```
